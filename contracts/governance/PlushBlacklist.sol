// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../interfaces/IPlushBlacklist.sol";

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/// @custom:security-contact security@plush.family
contract PlushBlacklist is
    IPlushBlacklist,
    Initializable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    mapping(address => bool) public blacklisted;

    /**
     * @dev Roles definitions
     */
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(OPERATOR_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
    }

    /**
     * @notice Checks if account is blacklisted
     * @param _account The address to check
     */
    function isBlacklisted(address _account) public view returns (bool) {
        return blacklisted[_account];
    }

    /**
     * @notice Adds account to blacklist
     * @param _account The address to blacklist
     */
    function blacklist(address _account) external onlyRole(OPERATOR_ROLE) {
        blacklisted[_account] = true;
        emit Blacklisted(_account);
    }

    /**
     * @notice Removes account from blacklist
     * @param _account The address to remove from the blacklist
     */
    function unBlacklist(address _account) external onlyRole(OPERATOR_ROLE) {
        blacklisted[_account] = false;
        emit UnBlacklisted(_account);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(UPGRADER_ROLE)
    {}
}
