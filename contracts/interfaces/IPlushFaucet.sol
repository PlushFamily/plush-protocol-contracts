// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

interface IPlushFaucet {

    /// @notice Pause contract
    function pause() external;

    /// @notice Unpause contract
    function unpause() external;

    /// @notice Get tokens from faucet
    function send() external;

    /**
     * @notice Set ERC-20 faucet token
     * @param newAddress contract address of new token
     */
    function setTokenAddress(address newAddress) external;

    /**
     * @notice Set faucet drip amount
     * @param amount new faucet drip amount
     */
    function setFaucetDripAmount(uint256 amount) external;

    /**
     * @notice Set the maximum amount of tokens that a user can receive for the entire time
     * @param amount new maximum amount
     */
    function setMaxReceiveAmount(uint256 amount) external;

    /**
     * @notice Set the time after which the user will be able to use the faucet
     * @param time new faucet time limit in seconds (timestamp)
     */
    function setFaucetTimeLimit(uint256 time) external;

    /// @notice Enable the LifeSpan NFT check for using the faucet
    function setEnableNFTCheck() external;

    /// @notice Disable the LifeSpan NFT check for using the faucet
    function setDisableNFTCheck() external;

    /**
     * @notice Withdraw the required number of tokens from the faucet
     * @param amount required token amount (ERC-20)
     * @param receiver address of the tokens recipient
     */
    function withdraw(uint256 amount, address receiver) external;

    /**
     * @notice Return how many tokens a user can get in total for the entire time
     * @return number of tokens in wei
     */
    function getMaxReceiveAmount() external view returns(uint256);

    /**
     * @notice Return how many tokens you can get at one time
     * @return number of tokens in wei
     */
    function getFaucetDripAmount() external view returns(uint256);

    /**
     * @notice Return the faucet balance
     * @return number of tokens in wei
     */
    function getFaucetBalance() external view returns(uint256);

    /**
     * @notice Return the time limit between interaction with the faucet
     * @return number of seconds (timestamp)
     */
    function getTimeLimit() external view returns(uint256);

    /**
     * @notice Return whether the faucet checks for the presence of LifeSpan NFT
     * @return boolean
     */
    function getIsTokenNFTCheck() external view returns(bool);

    /**
     * @notice Return the time how long the user has to wait before using the faucet again
     * @return number of seconds (timestamp)
     */
    function getUserTimeLimit(address receiver) external view returns(uint256);

    /**
     * @notice Check whether the user can use the faucet
     * @return boolean
     */
    function getCanTheAddressReceiveReward(address receiver) external view returns(bool);
}