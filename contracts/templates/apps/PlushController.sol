// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../../interfaces/IPlushController.sol";
import "../../interfaces/IPlushAccounts.sol";

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

contract PlushController is
    IPlushController,
    Initializable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    uint256 public constant version = 4;

    using SafeERC20Upgradeable for IERC20Upgradeable;

    IERC20Upgradeable public plush;
    IPlushAccounts public plushAccounts;

    mapping(address => uint256) public indexApps;
    address[] public appAddresses;

    /**
     * @dev Roles definitions
     */
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant APP_ROLE = keccak256("APP_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant BANKER_ROLE = keccak256("BANKER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize(
        IERC20Upgradeable plushAddress,
        IPlushAccounts plushAccountsAddress
    ) public initializer {
        plush = plushAddress;
        plushAccounts = plushAccountsAddress;

        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(BANKER_ROLE, msg.sender);
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
     * @notice Adding a new application address
     * @param appAddress contract address
     */
    function addNewAppAddress(address appAddress)
        external
        onlyRole(OPERATOR_ROLE)
    {
        require(
            indexApps[appAddress] > 0 == false,
            "Application doesn't exist"
        );

        indexApps[appAddress] = appAddresses.length + 1;
        appAddresses.push(appAddress);

        _grantRole(APP_ROLE, appAddress);

        emit AppAdded(appAddress, msg.sender);
    }

    /**
     * @notice Removing an application from the controller's application database
     * @param appAddress contract address
     */
    function deleteAppAddress(address appAddress)
        external
        onlyRole(OPERATOR_ROLE)
    {
        require(indexApps[appAddress] > 0, "Application doesn't exist");

        delete appAddresses[indexApps[appAddress] - 1];
        delete indexApps[appAddress];

        _revokeRole(APP_ROLE, appAddress);

        emit AppDeleted(appAddress, msg.sender);
    }

    /**
     * @notice Getting the balance of the controller (related to all its applications)
     * @return ERC-20 token balance in wei
     */
    function getBalance() public view returns (uint256) {
        return plushAccounts.getAccountBalance(address(this));
    }

    /**
     * @notice Withdrawal of tokens from the controller's balance
     * @param amount number of tokens to be withdrawn in wei
     */
    function withdraw(uint256 amount) external onlyRole(BANKER_ROLE) {
        require(getBalance() >= amount, "Insufficient funds");

        plushAccounts.withdrawByController(msg.sender, amount);

        emit Withdrawn(msg.sender, amount);
    }

    /**
     * @notice Get a list of all current application addresses
     * @return list of all application addresses
     */
    function getAppAddresses() public view returns (address[] memory) {
        return appAddresses;
    }

    /**
     * @notice Debiting user tokens by the controller
     * @param account user account
     * @param amount amount of tokens debited
     */
    function decreaseAccountBalance(address account, uint256 amount)
        external
        onlyRole(APP_ROLE)
    {
        plushAccounts.decreaseAccountBalance(account, amount);

        emit BalanceDecreased(msg.sender, account, amount);
    }

    /**
     * @notice Transfer tokens to the user account from the controller's balance
     * @param account receiver address
     * @param amount transfer amount
     */
    function increaseAccountBalance(address account, uint256 amount)
        external
        onlyRole(APP_ROLE)
    {
        plushAccounts.internalTransfer(account, amount);

        emit BalanceIncreased(msg.sender, account, amount);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(UPGRADER_ROLE)
    {}
}
