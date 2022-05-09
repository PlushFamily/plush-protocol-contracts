// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

import "../../interfaces/IPlushController.sol";
import "../../interfaces/IPlushAccounts.sol";

contract PlushController is Initializable, PausableUpgradeable, AccessControlUpgradeable, UUPSUpgradeable, IPlushController {

    uint256 public constant version = 3;

    using SafeERC20Upgradeable for IERC20Upgradeable;

    IERC20Upgradeable public plush;
    IPlushAccounts public plushAccounts;

    mapping(address => uint) public indexApps;
    address[] public appAddresses;

    /**
     * @dev Roles definitions
     */
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant BANKER_ROLE = keccak256("BANKER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize(IERC20Upgradeable plushAddress, IPlushAccounts plushAccountsAddress) initializer public {
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

    function addNewAppAddress(address appAddress) external onlyRole(OPERATOR_ROLE) {
        require(indexApps[appAddress] > 0 == false, "Application doesn't exist");

        indexApps[appAddress] = appAddresses.length + 1;
        appAddresses.push(appAddress);
    }

    function deleteAppAddress(address appAddress) external onlyRole(OPERATOR_ROLE) {
        require(indexApps[appAddress] > 0, "Application doesn't exist");

        delete appAddresses[indexApps[appAddress] - 1];
        delete indexApps[appAddress];
    }

    function getBalance() public view returns (uint256) {
        return plushAccounts.getAccountBalance(address(this));
    }

    function withdraw(uint256 amount) external onlyRole(BANKER_ROLE)  {
        require(getBalance() >= amount, "Insufficient funds");

        plushAccounts.withdrawByController(msg.sender, amount);
    }

    function getAppAddresses() public view returns (address[] memory) {
        return appAddresses;
    }

    function decreaseAccountBalance(address account, uint256 amount) external {
        plushAccounts.decreaseAccountBalance(account, amount);
    }

    function increaseAccountBalance(address account, uint256 amount) external {
        plushAccounts.internalTransfer(account, amount);
    }

    function _authorizeUpgrade(address newImplementation)
    internal
    onlyRole(UPGRADER_ROLE)
    override
    {}
}
