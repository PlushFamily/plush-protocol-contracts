// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

import "./IPlushFaucet.sol";

import "../token/ERC721/LifeSpan.sol";
import "./PlushAccounts.sol";

contract PlushFaucet is Initializable, PausableUpgradeable, AccessControlUpgradeable, UUPSUpgradeable, IPlushFaucet {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    IERC20Upgradeable public plush;
    LifeSpan public lifeSpan;
    PlushAccounts public plushAccounts;

    mapping(address=>uint256) private nextRequestAt;
    mapping(address=>uint256) private generalAmount;

    uint256 public faucetDripAmount;
    uint256 public faucetTime;
    uint256 private threshold;
    bool private tokenNFTCheck;

    /**
     * @dev Roles definitions
     */
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize(IERC20Upgradeable _plush, LifeSpan _lifeSpan, PlushAccounts _plushAccounts) initializer public {
        plush = _plush;
        lifeSpan = _lifeSpan;
        plushAccounts = _plushAccounts;

        faucetTime = 24 hours;
        faucetDripAmount = 1 * 10 ** 18;
        threshold = 100 * 10 ** 18;
        tokenNFTCheck = true;

        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
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

    /// @notice Get tokens from faucet
    function send() external {
        require(plush.balanceOf(address(this)) >= faucetDripAmount, "The faucet is empty");
        require(nextRequestAt[msg.sender] < block.timestamp, "Try again later");
        require(generalAmount[msg.sender] < threshold, "Quantity limit");

        if(tokenNFTCheck){
            require(lifeSpan.balanceOf(msg.sender) > 0, "You don't have LifeSpan Token");
        }

        // Next request from the address can be made only after faucetTime
        nextRequestAt[msg.sender] = block.timestamp + faucetTime;
        generalAmount[msg.sender] += faucetDripAmount;

        plush.approve(address(plushAccounts), faucetDripAmount);
        plushAccounts.deposit(msg.sender, faucetDripAmount);
    }

    function setTokenAddress(address _tokenAddr) external onlyRole(OPERATOR_ROLE) {
        plush = IERC20Upgradeable(_tokenAddr);
    }

    function setFaucetDripAmount(uint256 _amount) external onlyRole(OPERATOR_ROLE) {
        faucetDripAmount = _amount;
    }

    function setThreshold(uint256 _amount) external onlyRole(OPERATOR_ROLE) {
        threshold = _amount;
    }

    function setFaucetTime(uint256 _time) external onlyRole(OPERATOR_ROLE) {
        faucetTime = _time;
    }

    function setTokenNFTCheck(bool _isCheck) external onlyRole(OPERATOR_ROLE) {
        tokenNFTCheck = _isCheck;
    }

    function withdrawTokens(address _receiver, uint256 _amount) external onlyRole(OPERATOR_ROLE) {
        require(plush.balanceOf(address(this)) >= _amount, "FaucetError: Insufficient funds");
        require(plush.transfer(_receiver, _amount), "Transaction error.");
    }

    function getThreshold() external view returns(uint256) {
        return threshold;
    }

    function getFaucetDripAmount() external view returns(uint256) {
        return faucetDripAmount;
    }

    function getFaucetBalance() external view returns(uint256) {
        return plush.balanceOf(address(this));
    }

    function getDistributionTime() external view returns(uint256) {
        return faucetTime;
    }

    function getIsTokenNFTCheck() external view returns(bool) {
        return tokenNFTCheck;
    }

    function getDistributionOfAddress(address _receiver) external view returns(uint256) {
        if(nextRequestAt[_receiver] <= block.timestamp || nextRequestAt[_receiver] == 0){
            return 0;
        }

        return nextRequestAt[_receiver] - block.timestamp;
    }

    function getCanTheAddressReceiveReward(address _receiver) external view returns(bool) {
        require(plush.balanceOf(address(this)) >= faucetDripAmount, "The faucet is empty");
        require(nextRequestAt[_receiver] < block.timestamp, "Try again later");
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