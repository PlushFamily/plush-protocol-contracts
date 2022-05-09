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
    mapping(address=>uint256) private alreadyReceived;

    uint256 public faucetDripAmount;
    uint256 public faucetTimeLimit;
    uint256 private maxReceiveAmount;
    bool private tokenNFTCheck;

    /**
     * @dev Roles definitions
     */
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant BANKER_ROLE = keccak256("BANKER_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize(IERC20Upgradeable _plush, LifeSpan _lifeSpan, PlushAccounts _plushAccounts) initializer public {
        plush = _plush;
        lifeSpan = _lifeSpan;
        plushAccounts = _plushAccounts;

        faucetTimeLimit = 24 hours;
        faucetDripAmount = 1 * 10 ** 18;
        maxReceiveAmount = 100 * 10 ** 18;
        tokenNFTCheck = true;

        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(BANKER_ROLE, msg.sender);
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
        require(alreadyReceived[msg.sender] < maxReceiveAmount, "Quantity limit");

        if(tokenNFTCheck){
            require(lifeSpan.balanceOf(msg.sender) > 0, "You don't have LifeSpan Token");
        }

        // Next request from the address can be made only after faucetTime
        nextRequestAt[msg.sender] = block.timestamp + faucetTimeLimit;
        alreadyReceived[msg.sender] += faucetDripAmount;

        plush.approve(address(plushAccounts), faucetDripAmount);

        require(plush.allowance(address(this), address(plushAccounts)) >= faucetDripAmount);

        plushAccounts.deposit(msg.sender, faucetDripAmount);
    }

    /**
     * @notice Set ERC-20 faucet token
     * @param newAddress contract address of new token
     */
    function setTokenAddress(address newAddress) external onlyRole(OPERATOR_ROLE) {
        plush = IERC20Upgradeable(newAddress);
    }

    /**
     * @notice Set faucet drip amount
     * @param amount new faucet drip amount
     */
    function setFaucetDripAmount(uint256 amount) external onlyRole(OPERATOR_ROLE) {
        faucetDripAmount = amount;
    }

    /**
     * @notice Set the maximum amount of tokens that a user can receive for the entire time
     * @param amount new maximum amount
     */
    function setMaxReceiveAmount(uint256 amount) external onlyRole(OPERATOR_ROLE) {
        maxReceiveAmount = amount;
    }

    /**
     * @notice Set the time after which the user will be able to use the faucet
     * @param time new faucet time limit in seconds (timestamp)
     */
    function setFaucetTimeLimit(uint256 time) external onlyRole(OPERATOR_ROLE) {
        faucetTimeLimit = time;
    }

    /// @notice Enable the LifeSpan NFT check for using the faucet
    function setEnableNFTCheck() external onlyRole(OPERATOR_ROLE) {
        require(tokenNFTCheck == false, "NFT verification is already enabled");
        tokenNFTCheck = true;
    }

    /// @notice Disable the LifeSpan NFT check for using the faucet
    function setDisableNFTCheck() external onlyRole(OPERATOR_ROLE) {
        require(tokenNFTCheck == true, "NFT verification is already disabled");
        tokenNFTCheck = false;
    }

    /**
     * @notice Withdraw the required number of tokens from the faucet
     * @param amount required token amount (ERC-20)
     * @param receiver address of the tokens recipient
     */
    function withdraw(uint256 amount, address receiver) external onlyRole(BANKER_ROLE) {
        require(plush.balanceOf(address(this)) >= amount, "The faucet is empty");
        require(plush.transfer(receiver, amount), "Transaction error");
    }

    /**
     * @notice Return how many tokens a user can get in total for the entire time
     * @return number of tokens in wei
     */
    function getMaxReceiveAmount() public view returns(uint256) {
        return maxReceiveAmount;
    }

    /**
     * @notice Return how many tokens you can get at one time
     * @return number of tokens in wei
     */
    function getFaucetDripAmount() public view returns(uint256) {
        return faucetDripAmount;
    }

    /**
     * @notice Return the faucet balance
     * @return number of tokens in wei
     */
    function getFaucetBalance() public view returns(uint256) {
        return plush.balanceOf(address(this));
    }

    /**
     * @notice Return the time limit between interaction with the faucet
     * @return number of seconds (timestamp)
     */
    function getTimeLimit() public view returns(uint256) {
        return faucetTimeLimit;
    }

    /**
     * @notice Return whether the faucet checks for the presence of LifeSpan NFT
     * @return boolean
     */
    function getIsTokenNFTCheck() public view returns(bool) {
        return tokenNFTCheck;
    }

    /**
     * @notice Return the time how long the user has to wait before using the faucet again
     * @return number of seconds (timestamp)
     */
    function getUserTimeLimit(address receiver) external view returns(uint256) {
        if(nextRequestAt[receiver] <= block.timestamp || nextRequestAt[receiver] == 0){
            return 0;
        }

        return nextRequestAt[receiver] - block.timestamp;
    }

    /**
     * @notice Check whether the user can use the faucet
     * @return boolean
     */
    function getCanTheAddressReceiveReward(address receiver) external view returns(bool) {
        require(plush.balanceOf(address(this)) >= faucetDripAmount, "The faucet is empty");
        require(nextRequestAt[receiver] < block.timestamp, "Try again later");
        require(alreadyReceived[receiver] < maxReceiveAmount, "Quantity limit");

        if(tokenNFTCheck){
            require(lifeSpan.balanceOf(receiver) > 0, "Receiver don't have LifeSpan Token");
        }

        return true;
    }

    function _authorizeUpgrade(address newImplementation)
    internal
    onlyRole(UPGRADER_ROLE)
    override
    {}
}