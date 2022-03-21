// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";

import "../../token/ERC20/Plush.sol";
import "../../finance/PlushCoinWallets.sol";


contract PlushController is Ownable {

    uint256 version = 1;
    Plush plush;
    PlushCoinWallets plushCoinWallets;

    mapping (address => uint) indexWithdrawal;
    address[] withdrawalAddresses;

    mapping (address => uint) indexApps;
    address[] appAddresses;

    constructor(address _plushAddress, address _plushCoinWalletsAddress)
    {
        plush = Plush(_plushAddress);
        plushCoinWallets = PlushCoinWallets(_plushCoinWalletsAddress);
    }

    function addNewWithdrawalAddress(address _withdrawalAddress) external onlyOwner
    {
        require(!withdrawalAddressExist(_withdrawalAddress), "This address already exists.");

        indexWithdrawal[_withdrawalAddress] = withdrawalAddresses.length + 1;
        withdrawalAddresses.push(_withdrawalAddress);
    }

    function deleteWithdrawalAddress(address _withdrawalAddress) external onlyOwner
    {
        require(withdrawalAddressExist(_withdrawalAddress), "There is no such address.");

        delete withdrawalAddresses[indexWithdrawal[_withdrawalAddress] - 1];
        delete indexWithdrawal[_withdrawalAddress];
    }

    function addNewAppAddress(address _appAddress) external onlyOwner
    {
        require(!appAddressExist(_appAddress), "This app already exists.");

        indexApps[_appAddress] = appAddresses.length + 1;
        appAddresses.push(_appAddress);
    }

    function deleteAppAddress(address _appAddress) external onlyOwner
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

    function getVersion() external view returns (uint256)
    {
        return version;
    }
}
