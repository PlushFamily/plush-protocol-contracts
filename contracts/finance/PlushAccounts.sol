// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

import "../interfaces/IPlushAccounts.sol";
import "../interfaces/IPlushApps.sol";

contract PlushAccounts is Initializable, PausableUpgradeable, AccessControlUpgradeable, UUPSUpgradeable, IPlushAccounts {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    IERC20Upgradeable public plush;
    IPlushApps public plushApps;

    uint256 public minimumDeposit;
    address public plushFeeAddress;

    mapping(address => Account) public accounts;

    /**
     * @dev Roles definitions
     */
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize(IERC20Upgradeable _plush, IPlushApps _plushApps, address _plushFeeAddress) initializer public {
        plushApps = _plushApps;
        plush = _plush;
        minimumDeposit = 1 * 10 ** 18;
        plushFeeAddress = _plushFeeAddress;

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

    /**
     * @notice Deposit tokens to the account
     * @param account address
     * @param amount the amount to be deposited in tokens
     */
    function deposit(address account, uint256 amount) public {
        require(plush.balanceOf(msg.sender) >= amount, "Not enough balance");
        require(plush.allowance(msg.sender, address(this)) >= amount, "Not enough allowance");
        require(plush.transferFrom(msg.sender, address(this), amount), "Transaction error");

        increaseAccountBalance(account, amount);

        emit Deposited(msg.sender, account, amount);
    }

    /**
     * @notice Withdraw ERC-20 tokens from your account to the current address
     * @param amount the amount of tokens being withdrawn
     */
    function withdraw(uint256 amount) external {
        require(accounts[msg.sender].balance >= amount, "Not enough balance");
        require(plush.transfer(msg.sender, amount), "Transaction error");

        accounts[msg.sender].balance -= amount;

        emit Withdrawn(msg.sender, amount);
    }

    /**
     * @notice Withdraw ERC-20 tokens from your account to the current address
     * @param account output address
     * @param amount the amount of tokens being withdrawn
     */
    function withdrawByController(address account, uint256 amount) external {
        require(accounts[msg.sender].balance >= amount, "Not enough balance");
        require(plush.transfer(account, amount), "Transaction error");

        accounts[msg.sender].balance -= amount;
    }

    function increaseAccountBalance(address account, uint256 amount) private {
        require(amount >= minimumDeposit, "Less than minimum deposit");

        accounts[account].balance += amount;
    }

    function internalTransfer(address account, uint256 amount) public {
        require(accounts[msg.sender].balance >= amount, "Not enough balance(Sender).");

        accounts[msg.sender].balance -= amount;
        accounts[account].balance += amount;
    }

    function decreaseAccountBalance(address account, uint256 amount) public {
        require(accounts[account].balance >= amount, "Not enough balance.");
        require(plushApps.getAppStatus(msg.sender) == true, "You have no rights.");

        uint256 percent = amount * plushApps.getFeeApp(msg.sender) / 100000;

        accounts[account].balance -= amount;
        accounts[msg.sender].balance += amount - percent;
        accounts[plushFeeAddress].balance += percent;
    }

    function getPlushFeeAccountBalance() public view returns (uint256) {
        return accounts[plushFeeAddress].balance;
    }

    function getAccountBalance(address account) external view returns (uint256) {
        return accounts[account].balance;
    }

    function setMinimumDeposit(uint256 amount) external onlyRole(OPERATOR_ROLE) {
        minimumDeposit = amount;
    }

    function getMinimumDeposit() external view returns (uint256) {
        return minimumDeposit;
    }

    function setPlushFeeAddress(address account) public{
        plushFeeAddress = account;
    }

    function getPlushFeeAddress() public view returns (address) {
        return plushFeeAddress;
    }

    function _authorizeUpgrade(address newImplementation)
    internal
    onlyRole(UPGRADER_ROLE)
    override
    {}
}