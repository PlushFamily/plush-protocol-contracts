// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "../token/ERC20/Plush.sol";
import "../token/ERC721/PlushCoreToken.sol";
import "./PlushCoinWallets.sol";


contract PlushFaucet {
    Plush token;
    PlushCoreToken plushCoreToken;
    PlushCoinWallets plushCoinWallets;

    address public owner;
    mapping(address=>uint256) nextRequestAt;
    mapping(address=>uint256) generalAmount;
    uint256 faucetDripAmount;
    uint256 faucetTime;
    uint256 threshold;
    bool isActive;
    bool tokenNFTCheck;

    constructor (Plush _plushCoin, PlushCoreToken _plushCoreToken, PlushCoinWallets _plushCoinWallets)
    {
        token = _plushCoin;
        plushCoreToken = _plushCoreToken;
        plushCoinWallets = _plushCoinWallets;
        faucetTime = 24 hours;
        faucetDripAmount = 1 * 10 ** token.decimals();
        threshold = 100 * 10 ** token.decimals();
        owner = msg.sender;
        isActive = true;
        tokenNFTCheck = true;
    }

    modifier onlyOwner
    {
        require(msg.sender == owner, "FaucetError: Caller not owner");
        _;
    }

    function send(address _receiver) external
    {
        require(isActive == true, "FaucetError: Faucet is not active");
        require(token.balanceOf(address(this)) >= faucetDripAmount, "FaucetError: Empty");
        require(nextRequestAt[_receiver] < block.timestamp, "FaucetError: Try again later");
        require(generalAmount[_receiver] < threshold, "FaucetError: You have exceeded the maximum number of coins");

        if(tokenNFTCheck){
            require(plushCoreToken.balanceOf(_receiver) > 0, "FaucetError: You don't have NFT(Plush Core Token) to get reward");
        }

        // Next request from the address can be made only after faucetTime
        nextRequestAt[_receiver] = block.timestamp + faucetTime;
        generalAmount[_receiver] += faucetDripAmount;

        token.approve(address(plushCoinWallets), faucetDripAmount);
        plushCoinWallets.deposit(_receiver, faucetDripAmount);
    }

    function setTokenAddress(address _tokenAddr) external onlyOwner
    {
        token = Plush(_tokenAddr);
    }

    function setFaucetDripAmount(uint256 _amount) external onlyOwner
    {
        faucetDripAmount = _amount;
    }

    function setThreshold(uint256 _amount) external onlyOwner
    {
        threshold = _amount;
    }

    function setFaucetTime(uint256 _time) external onlyOwner
    {
        faucetTime = _time;
    }

    function setFaucetActive(bool _isActive) external onlyOwner
    {
        isActive = _isActive;
    }

    function setTokenNFTCheck(bool _isCheck) external onlyOwner
    {
        tokenNFTCheck = _isCheck;
    }

    function withdrawTokens(address _receiver, uint256 _amount) external onlyOwner
    {
        require(token.balanceOf(address(this)) >= _amount, "FaucetError: Insufficient funds");
        token.transfer(_receiver, _amount);
    }

    function getThreshold() external view returns(uint256)
    {
        return threshold;
    }

    function getFaucetDripAmount() external view returns(uint256)
    {
        return faucetDripAmount;
    }

    function getFaucetBalance() external view returns(uint256)
    {
        return token.balanceOf(address(this));
    }

    function getDistributionTime() external view returns(uint256)
    {
        return faucetTime;
    }

    function getIsFaucetActive() external view returns(bool)
    {
        return isActive;
    }

    function getIsTokenNFTCheck() external view returns(bool)
    {
        return tokenNFTCheck;
    }

    function getDistributionOfAddress(address _receiver) external view returns(uint256)
    {
        if(nextRequestAt[_receiver] <= block.timestamp || nextRequestAt[_receiver] == 0){
            return 0;
        }

        return nextRequestAt[_receiver] - block.timestamp;
    }

    function getCanTheAddressReceiveReward(address _receiver) external view returns(bool)
    {
        require(isActive == true, "Faucet is not active");
        require(token.balanceOf(address(this)) >= faucetDripAmount, "Faucet is empty");
        require(nextRequestAt[_receiver] < block.timestamp, "You received recently, try again later");
        require(generalAmount[_receiver] < threshold, "You have exceeded the maximum number of tokens");

        if(tokenNFTCheck){
            require(plushCoreToken.balanceOf(_receiver) > 0, "FaucetError: You don't have NFT(Plush Core Token) to get reward");
        }

        return true;
    }
}