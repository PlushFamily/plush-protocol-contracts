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
        require(amount >= minimumDeposit, "Less than minimum deposit");
        require(plush.balanceOf(msg.sender) >= amount, "Insufficient funds");
        require(plush.allowance(msg.sender, address(this)) >= amount, "Not enough allowance");
        require(plush.transferFrom(msg.sender, address(this), amount), "Transaction error");

        accounts[account].balance += amount;

        emit Deposited(msg.sender, account, amount);
    }

    /**
     * @notice Withdraw ERC-20 tokens from user account to the current wallet address
     * @param amount the amount of tokens being withdrawn
     */
    function withdraw(uint256 amount) external {
        require(accounts[msg.sender].balance >= amount, "Insufficient funds");
        require(plushApps.getAppExists(msg.sender) == false, "The wallet is a controller");
        require(plush.transfer(msg.sender, amount), "Transaction error");

        accounts[msg.sender].balance -= amount;

        emit Withdrawn(msg.sender, amount);
    }

    /**
     * @notice Withdrawal of tokens by the controller from his account to available withdrawal addresses
     * @param account withdraw address
     * @param amount the amount of tokens being withdrawn
     */
    function withdrawByController(address account, uint256 amount) external {
        require(accounts[msg.sender].balance >= amount, "Insufficient funds");
        require(plushApps.getAppStatus(msg.sender), "The wallet is not a active controller");
        require(plush.transfer(account, amount), "Transaction error");

        accounts[msg.sender].balance -= amount;

        emit ControllerWithdrawn(msg.sender, account, amount);
    }

    /**
     * @notice Transfer of tokens between accounts inside PlushAccounts
     * @param account receiver address
     * @param amount transfer amount
     */
    function internalTransfer(address account, uint256 amount) external {
        if (plushApps.getAppExists(msg.sender) == true){
            require(plushApps.getAppStatus(msg.sender), "The wallet is not a active controller");
        }

        require(accounts[msg.sender].balance >= amount, "Insufficient funds");

        accounts[msg.sender].balance -= amount;
        accounts[account].balance += amount;

        emit Transferred(msg.sender, account, amount);
    }

    /**
     * @notice Debiting user tokens by the controller
     * @param account user account
     * @param amount amount of tokens debited
     */
    function decreaseAccountBalance(address account, uint256 amount) public {
        require(accounts[account].balance >= amount, "Insufficient funds");
        require(plushApps.getAppStatus(msg.sender), "The wallet is not a active controller");

        uint256 percent = amount * plushApps.getFeeApp(msg.sender) / 100000; // Plush fee

        accounts[account].balance -= amount;
        accounts[msg.sender].balance += amount - percent;
        accounts[plushFeeAddress].balance += percent;

        emit Debited(msg.sender, account, amount);
    }

    /**
     * @notice Return Plush Fee account balance
     * @return account balance in wei
     */
    function getPlushFeeAccountBalance() public view returns (uint256) {
        return accounts[plushFeeAddress].balance;
    }

    /**
     * @notice Check account balance
     * @param account requesting account
     * @return account balance in wei
     */
    function getAccountBalance(address account) external view returns (uint256) {
        return accounts[account].balance;
    }

    /**
     * @notice Set minimum account deposit amount
     * @param amount minimum deposit amount in wei
     */
    function setMinimumDeposit(uint256 amount) external onlyRole(OPERATOR_ROLE) {
        minimumDeposit = amount;
    }

    /**
     * @notice Get minimum account deposit amount
     * @return minimum deposit amount in wei
     */
    function getMinimumDeposit() external view returns (uint256) {
        return minimumDeposit;
    }

    /**
     * @notice Set Plush fee address
     * @param account fee address
     */
    function setPlushFeeAddress(address account) external onlyRole(OPERATOR_ROLE) {
        plushFeeAddress = account;
    }

    /**
     * @notice Get Plush fee address
     * @return address
     */
    function getPlushFeeAddress() public view returns (address) {
        return plushFeeAddress;
    }

    function _authorizeUpgrade(address newImplementation)
    internal
    onlyRole(UPGRADER_ROLE)
    override
    {}
}