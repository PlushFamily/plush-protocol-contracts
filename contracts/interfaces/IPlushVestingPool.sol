// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IPlushVestingPool {
    /// @notice Pause contract
    function pause() external;

    /// @notice Unpause contract
    function unpause() external;

    /**
     * @notice Returns how many tokens are locked
     * @return Number of tokens in wei
     */
    function getLockBalance() external view returns (uint256);

    /**
     * @notice Returns how many tokens are unlock
     * @return Number of tokens in wei
     */
    function getUnLockBalance() external view returns (uint256);

    /**
     * @notice Withdrawal of unlocked tokens
     */
    function withdraw() external;

    /**
     * @notice Start release at IDO (unlocking the first part of the tokens and starting the reward every day)
     */
    function releaseAtIDO() external;

    /// @notice Emitted when user withdrawal unlocked tokens
    event WithdrawalTokens(address indexed receiver, uint256 amount);

    /// @notice Emitted when release at IDO
    event ReleaseIDO(address indexed receiver, uint256 time);
}
