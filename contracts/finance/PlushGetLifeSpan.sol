// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "./IPlushGetLifeSpan.sol";

import "../token/ERC721/LifeSpan.sol";
import "../finance/pools/PlushLifeSpanNFTCashbackPool.sol";

/// @custom:security-contact security@plush.family
contract PlushGetLifeSpan is Initializable, PausableUpgradeable, AccessControlUpgradeable, UUPSUpgradeable, IPlushGetLifeSpan {
    LifeSpan public lifeSpan;
    PlushLifeSpanNFTCashbackPool public plushLifeSpanNFTCashbackPool;

    address payable private royaltyAddress;  // Address for royalty transfer

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

    function initialize(LifeSpan _lifeSpan, PlushLifeSpanNFTCashbackPool _plushLifeSpanNFTCashbackPool, address payable _royaltyAddress) initializer public {
        plushLifeSpanNFTCashbackPool = _plushLifeSpanNFTCashbackPool;
        lifeSpan = _lifeSpan;
        royaltyAddress = _royaltyAddress;

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
        require(denyMultipleMinting == false, "Multiple minting is already prohibited");

        denyMultipleMinting = true;
    }

    /// @notice Allow a user to mint multiple tokens
    function setAllowMultipleMinting() external onlyRole(OPERATOR_ROLE) {
        require(denyMultipleMinting == true, "Multiple minting is already allowed");

        denyMultipleMinting = false;
    }

    /**
     * @notice Change mint price
     * @param newPrice new LifeSpan token mint price
     */
    function changeMintPrice(uint256 newPrice) external onlyRole(OPERATOR_ROLE) {
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
     * @notice Set new royalty address
     * @param _address new royalty address
     */
    function setRoyaltyAddress(address _address) external onlyRole(BANKER_ROLE) {
        royaltyAddress = payable(_address);

        emit RoyaltyAddressChanged(_address);
    }

    /**
     * @notice Set new LifeSpan contract address
     * @param _address new LifeSpan contract address
     */
    function setLifeSpanAddress(address _address) external onlyRole(OPERATOR_ROLE) {
        lifeSpan = LifeSpan(_address);

        emit LifeSpanAddressChanged(_address);
    }

    /**
     * @notice Get current royalty address
     * @return royalty address
     */
    function getRoyaltyAddress() public view returns (address payable) {
        return royaltyAddress;
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
     */
    function mint(address mintAddress) public payable {
        require(msg.value == mintPrice, "Incorrect amount");

        if (denyMultipleMinting) {
            require(lifeSpan.balanceOf(mintAddress) > 0 == false, "The specified address already has a LifeSpan token");
        }

        lifeSpan.safeMint(mintAddress);
        plushLifeSpanNFTCashbackPool.addRemunerationToAccount(mintAddress);

        emit TokenMinted(msg.sender, mintAddress, msg.value);
    }

    /**
     * @notice Free mint LifeSpan token for staffers
     * @param mintAddress where to enroll the LifeSpan token after minting
     */
    function freeMint(address mintAddress) public onlyRole(STAFF_ROLE) {
        if (denyMultipleMinting) {
            require(lifeSpan.balanceOf(mintAddress) > 0 == false, "The specified address already has a LifeSpan token");
        }

        lifeSpan.safeMint(mintAddress);

        emit TokenFreeMinted(msg.sender, mintAddress);
    }

    /**
     * @notice Withdraw mint royalty on royaltyAddress
     * @param amount withdraw amount
     */
    function withdraw(uint256 amount) external onlyRole(BANKER_ROLE) {
        require(amount <= address(this).balance, "The withdrawal amount exceeds the contract balance");
        (bool success, ) = royaltyAddress.call{value: amount}("");
        require(success, "Withdrawal Error");

        emit RoyaltyWithdrawn(amount, royaltyAddress);
    }

    function _authorizeUpgrade(address newImplementation)
    internal
    onlyRole(UPGRADER_ROLE)
    override
    {}
}