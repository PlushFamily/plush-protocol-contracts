// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IPlushLifeSpanNFTCashbackPool {

    struct Balance {
        uint256 balance;
        uint256 timeIsActive;
    }

    /// @notice Pause contract
    function pause() external;

    /// @notice Unpause contract
    function unpause() external;

    /**
     * @notice Add remuneration to account manually
     * @param account address to add remuneration
     * @param amount of tokens in wei
     */
    function addRemunerationToAccountManually(address account, uint256 amount) external;

    /**
    * @notice Add remuneration to account
     * @param account address to add remuneration
     */
    function addRemunerationToAccount(address account) external;

    /**
     * @notice Withdrawal tokens to address
     * @param amount of tokens in wei
     */
    function withdraw(uint256 amount) external;

    /**
     * @notice Set remuneration
     * @param amount of tokens in wei
     */
    function setRemuneration(uint256 amount) external;

    /**
     * @notice Set time lock
     * @param amount time in sec
     */
    function setTimeUnlock(uint256 amount) external;

    /**
     * @notice Switch to unlock all tokens
     */
    function unlockAllTokensSwitch() external;

    /**
     * @notice Get wallet amount in wei
     * @param account address
     * @return array of lock and unlock tokens
     */
    function getWalletAmount(address account) external view returns (uint256[] memory, uint256[] memory, uint256[] memory, uint256[] memory);

    /**
     * @notice Get remuneration
     * @return amount of tokens in wei
     */
    function getRemuneration() external view returns (uint256);

    /**
     * @notice Get time unlock
     * @return amount time in sec
     */
    function getTimeUnlock() external view returns (uint256);

    /// @notice Emitted when user withdrawal unlocked tokens
    event WithdrawalTokens(
        address indexed receiver,
        uint256 amount
    );

    /// @notice Emitted when added remuneration to account manually
    event RemunerationManually(
        address indexed receiver,
        address indexed user,
        uint256 amount
    );
}