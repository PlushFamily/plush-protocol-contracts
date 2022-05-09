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

    mapping (address => uint) public indexWithdrawal;
    address[] public withdrawalAddresses;

    mapping (address => uint) public indexApps;
    address[] public appAddresses;

    /**
     * @dev Roles definitions
     */
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
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
     * @notice Add new withdrawal address
     * @param withdrawalAddress new withdrawal address
     */
    function addNewWithdrawalAddress(address withdrawalAddress) external onlyRole(OPERATOR_ROLE) {
        require(indexWithdrawal[withdrawalAddress] > 0 == false, "This address has already been added");

        indexWithdrawal[withdrawalAddress] = withdrawalAddresses.length + 1;
        withdrawalAddresses.push(withdrawalAddress);
    }

    function deleteWithdrawalAddress(address withdrawalAddress) external onlyRole(OPERATOR_ROLE) {
        require(indexWithdrawal[withdrawalAddress] > 0, "There is no such address.");

        delete withdrawalAddresses[indexWithdrawal[withdrawalAddress] - 1];
        delete indexWithdrawal[withdrawalAddress];
    }

    function addNewAppAddress(address appAddress) external onlyRole(OPERATOR_ROLE) {
        require(indexApps[appAddress] > 0 == false, "This app already exists.");

        indexApps[appAddress] = appAddresses.length + 1;
        appAddresses.push(appAddress);
    }

    function deleteAppAddress(address appAddress) external onlyRole(OPERATOR_ROLE) {
        require(indexApps[appAddress] > 0, "There is no such app.");

        delete appAddresses[indexApps[appAddress] - 1];
        delete indexApps[appAddress];
    }

    function withdrawalAddressExist(address _address) public view returns (bool) {
        if (indexWithdrawal[_address] > 0) {
            return true;
        }

        return false;
    }

    function getAvailableBalanceForWithdrawal() public view returns (uint256) {
        return plushAccounts.getAccountBalance(address(this));
    }

    function withdraw(uint256 amount) external {
        require(indexWithdrawal[msg.sender] > 0, "Withdrawal is not available.");
        require(getAvailableBalanceForWithdrawal() >= amount, "Not enough balance.");

        plushAccounts.withdrawByController(msg.sender, amount);
    }

    function getWithdrawalAddresses() public view returns (address[] memory) {
        return withdrawalAddresses;
    }

    function getAppAddresses() public view returns (address[] memory) {
        return appAddresses;
    }

    function decreaseWalletAmountTrans(address _address, uint256 _amount) external {
        plushAccounts.decreaseAccountBalance(_address, _amount);
    }

    function increaseWalletAmountTrans(address _address, uint256 _amount) external {
        plushAccounts.internalTransfer(_address, _amount);
    }

    function _authorizeUpgrade(address newImplementation)
    internal
    onlyRole(UPGRADER_ROLE)
    override
    {}
}
