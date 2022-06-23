// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../interfaces/IPlushGetLifeSpan.sol";

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "../token/ERC721/LifeSpan.sol";
import "../finance/pools/PlushLifeSpanNFTCashbackPool.sol";

/// @custom:security-contact security@plush.family
contract PlushGetLifeSpan is
    IPlushGetLifeSpan,
    Initializable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    LifeSpan public lifeSpan;
    PlushLifeSpanNFTCashbackPool public plushLifeSpanNFTCashbackPool;

    address payable private feeAddress; // Address for fee transfer

    uint256 public mintPrice;
    bool public denyMultipleMinting;

    /**
     * @dev Roles definitions
     */
    bytes32 public constant STAFF_ROLE = keccak256("STAFF_ROLE");
    bytes32 public constant BANKER_ROLE = keccak256("BANKER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize(
        LifeSpan _lifeSpan,
        PlushLifeSpanNFTCashbackPool _plushLifeSpanNFTCashbackPool,
        address payable _feeAddress
    ) public initializer {
        plushLifeSpanNFTCashbackPool = _plushLifeSpanNFTCashbackPool;
        lifeSpan = _lifeSpan;
        feeAddress = _feeAddress;

        mintPrice = 0.001 ether;
        denyMultipleMinting = true;

        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(BANKER_ROLE, msg.sender);
        _grantRole(STAFF_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(OPERATOR_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
    }

    /// @notice Pause contract
    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /// @notice Unpause contract
    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    /// @notice Prohibit a user from minting multiple tokens
    function setDenyMultipleMinting() external onlyRole(OPERATOR_ROLE) {
        require(denyMultipleMinting == false, "Already prohibited");

        denyMultipleMinting = true;
    }

    /// @notice Allow a user to mint multiple tokens
    function setAllowMultipleMinting() external onlyRole(OPERATOR_ROLE) {
        require(denyMultipleMinting == true, "Already allowed");

        denyMultipleMinting = false;
    }

    /**
     * @notice Change mint price
     * @param newPrice new LifeSpan token mint price
     */
    function changeMintPrice(uint256 newPrice)
        external
        onlyRole(OPERATOR_ROLE)
    {
        mintPrice = newPrice;

        emit MintPriceChanged(newPrice);
    }

    /**
     * @notice Get current mint price
     * @return mint price in wei
     */
    function getMintPrice() public view returns (uint256) {
        return mintPrice;
    }

    /**
     * @notice Set new fee address
     * @param _address new fee address
     */
    function setFeeAddress(address _address) external onlyRole(BANKER_ROLE) {
        feeAddress = payable(_address);

        emit FeeAddressChanged(_address);
    }

    /**
     * @notice Set new LifeSpan contract address
     * @param _address new LifeSpan contract address
     */
    function setLifeSpanAddress(address _address)
        external
        onlyRole(OPERATOR_ROLE)
    {
        lifeSpan = LifeSpan(_address);

        emit LifeSpanAddressChanged(_address);
    }

    /**
     * @notice Get current fee address
     * @return fee address
     */
    function getFeeAddress() public view returns (address payable) {
        return feeAddress;
    }

    /**
     * @notice Get current LifeSpan address
     * @return LifeSpan address
     */
    function getLifeSpanTokenAddress() public view returns (address) {
        return address(lifeSpan);
    }

    /**
     * @notice Mint LifeSpan token
     * @param mintAddress where to enroll the LifeSpan token after minting
     * @param name of token User (metadata)
     * @param gender of token User (metadata)
     * @param birthdayDate in sec of token User (metadata)
     */
    function mint(address mintAddress, string memory name, uint256 gender, uint256 birthdayDate) public payable {
        require(msg.value == mintPrice, "Incorrect amount");

        if (denyMultipleMinting) {
            require(
                lifeSpan.balanceOf(mintAddress) > 0 == false,
                "Already has a LifeSpan token"
            );
        }

        lifeSpan.safeMint(mintAddress, name, gender, birthdayDate);
        plushLifeSpanNFTCashbackPool.addRemunerationToAccount(mintAddress);

        emit TokenMinted(msg.sender, mintAddress, msg.value);
    }

    /**
     * @notice Free mint LifeSpan token for staffers
     * @param mintAddress where to enroll the LifeSpan token after minting
     */
    function freeMint(address mintAddress, string memory name, uint256 gender, uint256 birthdayDate) public onlyRole(STAFF_ROLE) {
        if (denyMultipleMinting) {
            require(
                lifeSpan.balanceOf(mintAddress) > 0 == false,
                "Already has a LifeSpan token"
            );
        }

        lifeSpan.safeMint(mintAddress, name, gender, birthdayDate);

        emit TokenFreeMinted(msg.sender, mintAddress);
    }

    /**
     * @notice Withdraw mint fee on feeAddress
     * @param amount withdraw amount
     */
    function withdraw(uint256 amount) external onlyRole(BANKER_ROLE) {
        require(
            amount <= address(this).balance,
            "The withdrawal amount exceeds the contract balance"
        );

        (bool success, ) = feeAddress.call{value: amount}("");
        require(success, "Withdrawal Error");

        emit FeeWithdrawn(amount, feeAddress);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(UPGRADER_ROLE)
    {}
}
