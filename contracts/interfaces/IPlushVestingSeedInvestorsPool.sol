// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IPlushVestingSeedInvestorsPool {
    /// @notice Pause contract
    function pause() external;

    /// @notice Unpause contract
    function unpause() external;

    /**
     * @notice Reserve of a lot by USDT
     */
    function reserveByUSDT() external;

    /**
     * @notice Reserve of a lot by USDC
     */
    function reserveByUSDC() external;

    /**
     * @notice Complete purchase of a lot by USDT
     */
    function sellByUSDT() external;

    /**
     * @notice Complete purchase of a lot by USDC
     */
    function sellByUSDC() external;

    /**
    * @notice Cancel reserve lot manually
     */
    function cancelReserve() external;

    /**
     * @notice Sell lot manually
     * @param wallet address of the user to which we sell this lot
     */
    function sellManually(address wallet) external;

    /**
     * @notice Reserve lot manually
     * @param wallet address of the user to which we reserve this lot
     */
    function reserveManually(address wallet) external;

    /**
     * @notice Returns whether the lot was sold
     * @return bool lot was sold
     */
    function getIsSold() external view returns(bool);

    /**
    * @notice Returns whether the lot was reserved
     * @return bool lot was reserved
     */
    function getIsReserved() external view returns(bool);

    /**
     * @notice Returns how many tokens are locked
     * @return Number of tokens in wei
     */
    function getLockBalance() external view returns(uint256);

    /**
    * @notice Returns how many tokens are unlock
     * @return Number of tokens in wei
     */
    function getUnLockBalance() external view returns(uint256);

    /**
     * @notice Withdrawal of unlocked tokens
     */
    function withdraw() external;

    /**
     * @notice Start release at IDO (unlocking the first part of the tokens and starting the reward every day)
     */
    function releaseAtIDO() external;

    /// @notice Emitted when user reserve lot by USDT
    event ReserveByUSDT(
        address indexed receiver,
        uint256 amount
    );

    /// @notice Emitted when user reserve lot by USDC
    event ReserveByUSDC(
        address indexed receiver,
        uint256 amount
    );

    /// @notice Emitted when user sell lot by USDT
    event SellByUSDT(
        address indexed receiver,
        uint256 amount
    );

    /// @notice Emitted when user sell lot by USDC
    event SellByUSDC(
        address indexed receiver,
        uint256 amount
    );

    /// @notice Emitted when user sell lot
    event SellManually(
        address indexed receiver,
        uint256 amount
    );

    /// @notice Emitted when user sell
    event ReserveManually(
        address indexed receiver,
        uint256 amount
    );

    /// @notice Emitted when user withdrawal unlocked tokens
    event WithdrawalTokens(
        address indexed receiver,
        uint256 amount
    );

    /// @notice Emitted when release at IDO
    event ReleaseIDO(
        address indexed sender,
        uint256 time
    );
}