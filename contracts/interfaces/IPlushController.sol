// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IPlushController {

    /// @notice Pause contract
    function pause() external;

    /// @notice Unpause contract
    function unpause() external;

    /**
     * @notice Adding a new application address
     * @param appAddress contract address
     */
    function addNewAppAddress(address appAddress) external;

    /**
     * @notice Removing an application from the controller's application database
     * @param appAddress contract address
     */
    function deleteAppAddress(address appAddress) external;

    /**
     * @notice Getting the balance of the controller (related to all its applications)
     * @return ERC-20 token balance in wei
     */
    function getBalance() external view returns (uint256);

    /**
     * @notice Withdrawal of tokens from the controller's balance
     * @param amount of tokens to be withdrawn in wei
     */
    function withdraw(uint256 amount) external;

    /**
     * @notice Get a list of all current application addresses
     * @return list of all application addresses
     */
    function getAppAddresses() external view returns (address[] memory);

    /**
     * @notice Debiting user tokens by the controller
     * @param account user account
     * @param amount amount of tokens debited
     */
    function decreaseAccountBalance(address account, uint256 amount) external;

    /**
     * @notice Transfer tokens to the user account from the controller's balance
     * @param account receiver address
     * @param amount transfer amount
     */
    function increaseAccountBalance(address account, uint256 amount) external;

    /// @notice Emitted when was the new app added
    event AppAdded(
        address indexed appAddress,
        address indexed operator
    );

    /// @notice Emitted when the app was deleted
    event AppDeleted(
        address indexed appAddress,
        address indexed operator
    );

    /// @notice Emitted when were the funds withdrawn from the controller account
    event Withdrawn(
        address indexed recipient,
        uint256 amount
    );

    /// @notice Emitted when were the funds debited from the user's account
    event BalanceDecreased(
        address indexed app,
        address indexed account,
        uint256 amount
    );

    /// @notice Emitted when were the funds transferred to the user's account
    event BalanceIncreased(
        address indexed app,
        address indexed account,
        uint256 amount
    );

}