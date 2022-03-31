// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "../../token/ERC20/Plush.sol";
import "../../finance/PlushCoinWallets.sol";


contract PlushController is Initializable, PausableUpgradeable, AccessControlUpgradeable, UUPSUpgradeable {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    uint256 public constant version = 2;
    Plush public plush;
    PlushCoinWallets public plushCoinWallets;

    mapping (address => uint) public indexWithdrawal;
    address[] public withdrawalAddresses;

    mapping (address => uint) public indexApps;
    address[] public appAddresses;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() public initializer {}

    function initialize(Plush _plush, PlushCoinWallets _plushCoinWallets) public initializer
    {
        plush = _plush;
        plushCoinWallets = _plushCoinWallets;

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

    function addNewWithdrawalAddress(address _withdrawalAddress) external onlyRole(OPERATOR_ROLE)
    {
        require(!withdrawalAddressExist(_withdrawalAddress), "This address already exists.");

        indexWithdrawal[_withdrawalAddress] = withdrawalAddresses.length + 1;
        withdrawalAddresses.push(_withdrawalAddress);
    }

    function deleteWithdrawalAddress(address _withdrawalAddress) external onlyRole(OPERATOR_ROLE)
    {
        require(withdrawalAddressExist(_withdrawalAddress), "There is no such address.");

        delete withdrawalAddresses[indexWithdrawal[_withdrawalAddress] - 1];
        delete indexWithdrawal[_withdrawalAddress];
    }

    function addNewAppAddress(address _appAddress) external onlyRole(OPERATOR_ROLE)
    {
        require(!appAddressExist(_appAddress), "This app already exists.");

        indexApps[_appAddress] = appAddresses.length + 1;
        appAddresses.push(_appAddress);
    }

    function deleteAppAddress(address _appAddress) external onlyRole(OPERATOR_ROLE)
    {
        require(appAddressExist(_appAddress), "There is no such app.");

        delete appAddresses[indexApps[_appAddress] - 1];
        delete indexApps[_appAddress];
    }

    function withdrawalAddressExist(address _address) public view returns (bool)
    {
        if (indexWithdrawal[_address] > 0) {
            return true;
        }

        return false;
    }

    function appAddressExist(address _address) public view returns (bool)
    {
        if (indexApps[_address] > 0) {
            return true;
        }

        return false;
    }

    function getAvailableBalanceForWithdrawal() public view returns (uint256)
    {
        return plushCoinWallets.getWalletAmount(address(this));
    }

    function withdraw(uint256 _amount) external
    {
        require(withdrawalAddressExist(msg.sender), "Withdrawal is not available.");
        require(getAvailableBalanceForWithdrawal() >= _amount, "Not enough balance.");

        plushCoinWallets.withdrawByController(_amount, msg.sender);
    }

    function getAllWithdrawalAddresses() public view returns (address[] memory)
    {
        return withdrawalAddresses;
    }

    function getAllAppAddresses() public view returns (address[] memory)
    {
        return appAddresses;
    }

    function decreaseWalletAmountTrans(address _address, uint256 _amount) external
    {
        plushCoinWallets.decreaseWalletAmount(_address, _amount);
    }

    function increaseWalletAmountTrans(address _address, uint256 _amount) external
    {
        plushCoinWallets.internalTransfer(_address, _amount);
    }

    function getVersion() public pure returns (uint256)
    {
        return version;
    }

    function _authorizeUpgrade(address newImplementation)
    internal
    onlyRole(UPGRADER_ROLE)
    override
    {}
}
