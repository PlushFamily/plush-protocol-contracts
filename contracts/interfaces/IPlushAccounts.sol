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
     * @notice Withdraw ERC-20 tokens from user account to the current wallet address
     * @param amount the amount of tokens being withdrawn
     */
    function withdraw(uint256 amount) external;


    /**
     * @notice Withdrawal of tokens by the controller from his account to available withdrawal addresses
     * @param account withdraw address
     * @param amount the amount of tokens being withdrawn
     */
    function withdrawByController(address account, uint256 amount) external;

    /**
     * @notice Transfer of tokens between accounts inside PlushAccounts
     * @param account receiver address
     * @param amount transfer amount
     */
    function internalTransfer(address account, uint256 amount) external;

    /**
     * @notice Debiting user tokens by the controller
     * @param account user account
     * @param amount amount of tokens debited
     */
    function decreaseAccountBalance(address account, uint256 amount) external;

    /**
     * @notice Return Plush Fee account balance
     * @return account balance in wei
     */
    function getPlushFeeAccountBalance() external view returns (uint256);

    /**
     * @notice Check account balance
     * @param account requesting account
     * @return account balance in wei
     */
    function getAccountBalance(address account) external view returns (uint256);

    /**
     * @notice Set minimum account deposit amount
     * @param amount minimum deposit amount in wei
     */
    function setMinimumDeposit(uint256 amount) external;

    /**
     * @notice Get minimum account deposit amount
     * @return minimum deposit amount in wei
     */
    function getMinimumDeposit() external view returns (uint256);

    /**
     * @notice Set Plush fee address
     * @param amount fee amount in wei
     * @return address
     */
    function setPlushFeeAddress(address account) external;

    /**
     * @notice Get Plush fee address
     * @return address
     */
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

    /// @notice Emitted when were the tokens withdrawn from the account to the user address
    event ControllerWithdrawn(
        address indexed controller,
        address indexed account,
        uint256 amount
    );

    /// @notice Emitted when were the tokens transferred inside PlushAccounts
    event Transferred(
        address indexed sender,
        address indexed recipient,
        uint256 amount
    );

    /// @notice Emitted when the controller debits the user's tokens
    event Debited(
        address indexed controller,
        address indexed account,
        uint256 amount
    );

}