// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IPlushRewardYear {
    struct Account {
        uint256 lastDateWithdraw;
    }

    struct DateT {
        uint16 year;
        uint8 month;
        uint8 day;
    }

    /// @notice Pause contract
    function pause() external;

    /// @notice Unpause contract
    function unpause() external;

    /**
     * @notice Check account balance
     * @param lifeSpanId requesting account
     * @return uint256 balance in wei
     */
    function getBalance(uint256 lifeSpanId)
    external
    view
    returns (uint256);

    /**
     * @notice Withdraw reward tokens
     * @param lifeSpanId requesting account
     */
    function withdraw(uint256 lifeSpanId)
    external;

    /// @notice Emitted withdraw
    event Withdraw(
        address indexed addr,
        uint256 amount
    );
}
