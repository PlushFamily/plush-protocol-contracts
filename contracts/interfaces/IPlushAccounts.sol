// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IPlushAccounts {

    struct Account {
        uint256 balance;
    }

    /// @notice Pause contract
    function pause() external;

    /// @notice Unpause contract
    function unpause() external;

    /**
     * @notice Deposit tokens to the account
     * @param account wallet address
     * @param amount the amount to be deposited in tokens
     */
    function deposit(address account, uint256 amount) external;

    /**
     * @notice Withdraw ERC-20 tokens from your account to the current address
     * @param amount the amount of tokens being withdrawn
     */
    function withdraw(uint256 amount) external;


    /**
     * @notice Withdraw ERC-20 tokens from your account to the current address
     * @param account output address
     * @param amount the amount of tokens being withdrawn
     */
    function withdrawByController(address account, uint256 amount) external;

    function internalTransfer(address account, uint256 amount) external;

    function decreaseAccountBalance(address account, uint256 amount) external;

    function getPlushFeeAccountBalance() external view returns (uint256);

    function getAccountBalance(address account) external view returns (uint256);

    function setMinimumDeposit(uint256 amount) external;

    function getMinimumDeposit() external view returns (uint256);

    function setPlushFeeAddress(address account) external;

    function getPlushFeeAddress() external view returns (address);

    /// @notice Emitted when were the tokens deposited to the account
    event Deposited(
        address indexed sender,
        address indexed account,
        uint256 amount
    );

    /// @notice Emitted when were the tokens withdrawn from the account to the user address
    event Withdrawn(
        address indexed account,
        uint256 amount
    );

}