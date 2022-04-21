// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "../token/ERC721/LifeSpan.sol";
import "../finance/pools/PlushLifeSpanNFTCashbackPool.sol";

/// @custom:security-contact security@plush.family
contract PlushGetLifeSpan is Initializable, PausableUpgradeable, AccessControlUpgradeable, UUPSUpgradeable {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    event lifeSpanTokenTokenChecked
    (
        address _holder,
        uint _bal,
        bool _result
    );

    PlushLifeSpanNFTCashbackPool public plushLifeSpanNFTCashbackPool;
    LifeSpan public lifeSpan;
    address payable private safeAddress;
    uint256 public mintPrice;
    bool public tokenNFTCheck;

    event TokenMinted(address indexed purchaser, address indexed beneficiary, uint256 amount);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize(LifeSpan _lifeSpan, address payable _safeAddress, PlushLifeSpanNFTCashbackPool _plushLifeSpanNFTCashbackPool) initializer public
    {
        plushLifeSpanNFTCashbackPool = _plushLifeSpanNFTCashbackPool;
        lifeSpan = _lifeSpan;
        safeAddress = _safeAddress;
        mintPrice = 0.001 ether;
        tokenNFTCheck = true;

        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(OPERATOR_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
    }

    function pause() public onlyRole(PAUSER_ROLE)
    {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE)
    {
        _unpause();
    }

    function checkUserLifeSpanToken(address _address) private returns (bool)
    {
        bool result = false;

        if (lifeSpan.balanceOf(_address) > 0) {
            result = true;
        }

        emit lifeSpanTokenTokenChecked(_address, lifeSpan.balanceOf(_address), result);

        return result;
    }

    function changeTokenCheckStatus() public onlyRole(OPERATOR_ROLE)
    {
        tokenNFTCheck = !tokenNFTCheck;
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
        safeAddress = payable(_address);
    }

    function setLifeSpanAddress(address _address) external onlyRole(OPERATOR_ROLE)
    {
        lifeSpan = LifeSpan(_address);
    }

    function getSafeAddress() public view returns (address payable)
    {
        return safeAddress;
    }

    function getLifeSpanTokenAddress() public view returns (address)
    {
        return address(lifeSpan);
    }

    function mint(address _mintAddress) public payable
    {
        require(msg.value == mintPrice, "Incorrect amount");

        if (tokenNFTCheck) {
            require(checkUserLifeSpanToken(_mintAddress) == false, "You already have a LifeSpan token");
        }

        lifeSpan.safeMint(_mintAddress);
        plushLifeSpanNFTCashbackPool.addRemunerationToAccount(_mintAddress);

        emit TokenMinted(_msgSender(), _mintAddress, msg.value);
    }

    function withdraw(uint256 _amount) external onlyRole(OPERATOR_ROLE)
    {
        (bool success, ) = safeAddress.call{value: _amount}("");
        require(success, "Transfer failed.");
    }

    function _authorizeUpgrade(address newImplementation)
    internal
    onlyRole(UPGRADER_ROLE)
    override
    {}
}