// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./PlushApps.sol";
import "../token/ERC20/Plush.sol";

contract PlushCoinWallets is Ownable {

    Plush plush;
    PlushApps plushApps;

    uint256 minimumBet;
    address plushFeeWallet;

    struct Wallet
    {
        uint256 balance;
    }

    mapping(address => Wallet) public walletInfo;

    constructor(address _plushAddress, address _plushAppsAddress, address _plushFeeAddress)
    {
        plushApps = PlushApps(_plushAppsAddress);
        plush = Plush(_plushAddress);
        minimumBet = 1 * 10 ** plush.decimals();
        plushFeeWallet = _plushFeeAddress;
    }

    function deposit(uint256 _amount) public
    {
        require(plush.balanceOf(msg.sender) >= _amount, "Not enough balance.");
        require(plush.allowance(msg.sender, address(this)) >= _amount, "Not enough allowance.");

        increaseWalletAmount(msg.sender, _amount);
        plush.transferFrom(msg.sender, address(this), _amount);
    }

    function withdraw(uint256 _amount) external
    {
        require(walletInfo[msg.sender].balance >= _amount, "Not enough balance.");

        walletInfo[msg.sender].balance -= _amount;
        plush.transfer(msg.sender, _amount);
    }

    function withdrawByController(uint256 _amount, address _address) external
    {
        require(walletInfo[msg.sender].balance >= _amount, "Not enough balance.");

        walletInfo[msg.sender].balance -= _amount;
        plush.transfer(_address, _amount);
    }

    function increaseWalletAmount(address _wallet, uint256 _amount) private
    {
        require(_amount >= minimumBet, "Less than minimum deposit.");

        walletInfo[_wallet].balance += _amount;
    }

    function decreaseWalletAmount(address _wallet, uint256 _amount) public
    {
        require(walletInfo[_wallet].balance >= _amount, "Not enough balance.");
        require(plushApps.getIsAddressActive(msg.sender) == true, "You have no rights.");

        uint256 percent = _amount * plushApps.getFeeApp(msg.sender) / 100000;

        walletInfo[_wallet].balance -= _amount;
        walletInfo[msg.sender].balance += _amount - percent;
        walletInfo[plushFeeWallet].balance += percent;
    }

    function getPlushFeeWalletAmount() external onlyOwner view returns(uint256)
    {
        return walletInfo[plushFeeWallet].balance;
    }

    function getWalletAmount(address _wallet) external view returns(uint256)
    {
        return walletInfo[_wallet].balance;
    }

    function setMinimumAmount(uint256 _amount) external onlyOwner
    {
        minimumBet = _amount;
    }

    function getMinimumAmount() external view returns(uint256)
    {
        return minimumBet;
    }

    function setPlushFeeAddress(address _address) external onlyOwner
    {
        plushFeeWallet = _address;
    }

    function getPlushFeeAddress() external onlyOwner view returns(address)
    {
        return plushFeeWallet;
    }
}