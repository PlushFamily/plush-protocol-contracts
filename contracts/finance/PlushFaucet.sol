// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "../token/ERC20/Plush.sol";
import "../token/ERC721/LifeSpan.sol";
import "./PlushAccounts.sol";


contract PlushFaucet is Initializable, PausableUpgradeable, AccessControlUpgradeable, UUPSUpgradeable {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    Plush public token;
    LifeSpan public lifeSpan;
    PlushAccounts public plushAccounts;

    address public owner;
    mapping(address=>uint256) private nextRequestAt;
    mapping(address=>uint256) private generalAmount;
    uint256 public faucetDripAmount;
    uint256 public faucetTime;
    uint256 private threshold;
    bool private tokenNFTCheck;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize(Plush _plushCoin, LifeSpan _lifeSpan, PlushAccounts _plushAccounts) initializer public
    {
        token = _plushCoin;
        lifeSpan = _lifeSpan;
        plushAccounts = _plushAccounts;
        faucetTime = 24 hours;
        faucetDripAmount = 1 * 10 ** token.decimals();
        threshold = 100 * 10 ** token.decimals();
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

    function send(address _receiver) external
    {
        require(token.balanceOf(address(this)) >= faucetDripAmount, "Empty");
        require(nextRequestAt[_receiver] < block.timestamp, "Time limit");
        require(generalAmount[_receiver] < threshold, "Quantity limit");

        if(tokenNFTCheck){
            require(lifeSpan.balanceOf(_receiver) > 0, "You don't have LifeSpan Token");
        }

        // Next request from the address can be made only after faucetTime
        nextRequestAt[_receiver] = block.timestamp + faucetTime;
        generalAmount[_receiver] += faucetDripAmount;

        token.approve(address(plushAccounts), faucetDripAmount);
        plushAccounts.deposit(_receiver, faucetDripAmount);
    }

    function setTokenAddress(address _tokenAddr) external onlyRole(OPERATOR_ROLE)
    {
        token = Plush(_tokenAddr);
    }

    function setFaucetDripAmount(uint256 _amount) external onlyRole(OPERATOR_ROLE)
    {
        faucetDripAmount = _amount;
    }

    function setThreshold(uint256 _amount) external onlyRole(OPERATOR_ROLE)
    {
        threshold = _amount;
    }

    function setFaucetTime(uint256 _time) external onlyRole(OPERATOR_ROLE)
    {
        faucetTime = _time;
    }

    function setTokenNFTCheck(bool _isCheck) external onlyRole(OPERATOR_ROLE)
    {
        tokenNFTCheck = _isCheck;
    }

    function withdrawTokens(address _receiver, uint256 _amount) external onlyRole(OPERATOR_ROLE)
    {
        require(token.balanceOf(address(this)) >= _amount, "FaucetError: Insufficient funds");
        require(token.transfer(_receiver, _amount), "Transaction error.");
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
        require(token.balanceOf(address(this)) >= faucetDripAmount, "Faucet is empty");
        require(nextRequestAt[_receiver] < block.timestamp, "Time limit");
        require(generalAmount[_receiver] < threshold, "Quantity limit");

        if(tokenNFTCheck){
            require(lifeSpan.balanceOf(_receiver) > 0, "You don't have LifeSpan Token");
        }

        return true;
    }

    function _authorizeUpgrade(address newImplementation)
    internal
    onlyRole(UPGRADER_ROLE)
    override
    {}
}