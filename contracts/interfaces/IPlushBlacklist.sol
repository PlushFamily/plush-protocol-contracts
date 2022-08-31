// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IPlushBlacklist {
    /**
     * @notice Checks if account is blacklisted
     * @param _account The address to check
     */
    function isBlacklisted(address _account) external view returns (bool);

    /**
     * @notice Adds account to blacklist
     * @param _account The address to blacklist
     */
    function blacklist(address _account) external;

    /**
     * @notice Removes account from blacklist
     * @param _account The address to remove from the blacklist
     */
    function unBlacklist(address _account) external;

    /// @notice Emitted when when the account was blacklisted
    event Blacklisted(address indexed account);

    /// @notice Emitted when the account was removed from the blacklist
    event UnBlacklisted(address indexed account);
}
