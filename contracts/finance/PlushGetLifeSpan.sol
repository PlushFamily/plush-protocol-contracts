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
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize(LifeSpan _lifeSpan, PlushLifeSpanNFTCashbackPool _plushLifeSpanNFTCashbackPool, address payable _royaltyAddress) initializer public
    {
        plushLifeSpanNFTCashbackPool = _plushLifeSpanNFTCashbackPool;
        lifeSpan = _lifeSpan;
        royaltyAddress = _royaltyAddress;

        mintPrice = 0.001 ether;
        denyMultipleMinting = true;

        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(STAFF_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(OPERATOR_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
    }

    /// @notice Pause contract
    function pause() public onlyRole(PAUSER_ROLE)
    {
        _pause();
    }

    /// @notice Unpause contract
    function unpause() public onlyRole(PAUSER_ROLE)
    {
        _unpause();
    }

    function checkUserLifeSpanToken(address _address) private view returns (bool)
    {

        if (lifeSpan.balanceOf(_address) > 0) {
            return true;
        }

        return false;
    }

    function changeTokenCheckStatus() public onlyRole(OPERATOR_ROLE)
    {
        denyMultipleMinting = !denyMultipleMinting;
    }

    function changeMintPrice(uint256 _price) public onlyRole(OPERATOR_ROLE)
    {
        mintPrice = _price;
    }

    function getMintPrice() external view returns (uint256)
    {
        return mintPrice;
    }

    function setSafeAddress(address _address) external onlyRole(OPERATOR_ROLE)
    {
        royaltyAddress = payable(_address);
    }

    function setLifeSpanAddress(address _address) external onlyRole(OPERATOR_ROLE)
    {
        lifeSpan = LifeSpan(_address);
    }

    function getSafeAddress() public view returns (address payable)
    {
        return royaltyAddress;
    }

    function getLifeSpanTokenAddress() public view returns (address)
    {
        return address(lifeSpan);
    }

    function mint(address _mintAddress) public payable
    {
        require(msg.value == mintPrice, "Incorrect amount");

        if (denyMultipleMinting) {
            require(checkUserLifeSpanToken(_mintAddress) == false, "The specified address already has a LifeSpan token");
        }

        lifeSpan.safeMint(_mintAddress);
        plushLifeSpanNFTCashbackPool.addRemunerationToAccount(_mintAddress);

        emit TokenMinted(_msgSender(), _mintAddress, msg.value);
    }

    function freeMint(address _mintAddress) public onlyRole(STAFF_ROLE)
    {
        if (denyMultipleMinting) {
            require(checkUserLifeSpanToken(_mintAddress) == false, "The specified address already has a LifeSpan token");
        }

        lifeSpan.safeMint(_mintAddress);

        emit TokenFreeMinted(_msgSender(), _mintAddress);
    }

    function withdraw(uint256 amount) external onlyRole(OPERATOR_ROLE)
    {
        (bool success, ) = royaltyAddress.call{value: amount}("");
        require(success, "Withdrawal Error");
    }

    function _authorizeUpgrade(address newImplementation)
    internal
    onlyRole(UPGRADER_ROLE)
    override
    {}
}