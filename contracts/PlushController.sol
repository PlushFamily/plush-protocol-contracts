// SPDX-License-Identifier: UNLISCENSED
pragma solidity ^0.8.2;

import "./Plush.sol";
import "./PlushCoinWallets.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PlushController is Ownable {

    Plush plush;
    PlushCoinWallets plushCoinWallets;

    mapping (address => uint) index;
    address[] withdrawalAddresses;

    constructor(address _plushAddress, address _plushCoinWalletsAddress)
    {
        plush = Plush(_plushAddress);
        plushCoinWallets = PlushCoinWallets(_plushCoinWalletsAddress);
    }

    function addNewWithdrawalAddress(address _withdrawalAddress) external onlyOwner
    {
        require(!withdrawalAddressExist(_withdrawalAddress), "This address already exists.");

        index[_withdrawalAddress] = withdrawalAddresses.length + 1;
        withdrawalAddresses.push(_withdrawalAddress);
    }

    function deleteWithdrawalAddress(address _address) external onlyOwner
    {
        require(withdrawalAddressExist(_address), "There is no such address.");

        delete withdrawalAddresses[index[_address] - 1];
        delete index[_address];
    }

    function withdrawalAddressExist(address _address) public view returns (bool)
    {
        if (index[_address] > 0) {
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
}
