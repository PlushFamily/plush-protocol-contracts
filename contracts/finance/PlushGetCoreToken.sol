// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "../token/ERC721/PlushCoreToken.sol";

/// @custom:security-contact security@plush.family
contract PlushGetCoreToken is Initializable, PausableUpgradeable, AccessControlUpgradeable, UUPSUpgradeable {

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    event coreTokenChecked
    (
        address _holder,
        uint _bal,
        bool _result
    );

    PlushCoreToken plushCoreToken;
    address payable private safeAddress;
    uint256 public mintPrice;
    bool public tokenNFTCheck;

    event TokenMinted(address indexed purchaser, address indexed beneficiary, uint256 amount);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize(PlushCoreToken _plushCore, address payable _safeAddress) initializer public {
        plushCoreToken = _plushCore;
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

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function checkUserCoreToken(address _address) private returns (bool)
    {
        bool result = false;

        if (plushCoreToken.balanceOf(_address) > 0) {
            result = true;
        }

        emit coreTokenChecked(_address, plushCoreToken.balanceOf(_address), result);

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

    function setCoreTokenAddress(address _address) external onlyRole(OPERATOR_ROLE)
    {
        plushCoreToken = PlushCoreToken(_address);
    }

    function getSafeAddress() public view returns (address payable)
    {
        return safeAddress;
    }

    function getCoreTokenAddress() public view returns (address)
    {
        return address(plushCoreToken);
    }

    function mint(address _mintAddress) payable public
    {
        require(msg.value == mintPrice, "Incorrect amount");

        if (tokenNFTCheck) {
            require(checkUserCoreToken(_mintAddress) == false, "You already have a Core token");
        }

        plushCoreToken.safeMint(_mintAddress);

        emit TokenMinted(_msgSender(), _mintAddress, msg.value);

        _forwardFunds();
    }

    function _forwardFunds() internal {
        (bool success, ) = safeAddress.call{value: msg.value}("");
        require(success, "Transfer failed.");
    }

    function _authorizeUpgrade(address newImplementation)
    internal
    onlyRole(UPGRADER_ROLE)
    override
    {}
}