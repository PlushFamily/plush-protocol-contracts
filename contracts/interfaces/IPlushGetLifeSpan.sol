// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IPlushGetLifeSpan {
    /// @notice Pause contract
    function pause() external;

    /// @notice Unpause contract
    function unpause() external;

    /// @notice Prohibit a user from minting multiple tokens
    function setDenyMultipleMinting() external;

    /// @notice Allow a user to mint multiple tokens
    function setAllowMultipleMinting() external;

    /**
     * @notice Change mint price
     * @param newPrice new price
     */
    function changeMintPrice(uint256 newPrice) external;

    /**
     * @notice Get actual mint price
     * @return mint price in wei
     */
    function getMintPrice() external view returns (uint256);

    /**
     * @notice Set new fee address
     * @param _address new fee address
     */
    function setFeeAddress(address _address) external;

    /**
     * @notice Set new LifeSpan contract address
     * @param _address new LifeSpan contract address
     */
    function setLifeSpanAddress(address _address) external;

    /**
     * @notice Get current fee address
     * @return fee address
     */
    function getFeeAddress() external view returns (address payable);

    /**
     * @notice Get current LifeSpan address
     * @return LifeSpan address
     */
    function getLifeSpanTokenAddress() external view returns (address);

    /**
     * @notice Mint LifeSpan token
     * @param mintAddress where to enroll the LifeSpan token after minting
     * @param name of token User (metadata)
     * @param gender of token User (metadata)
     * @param birthdayDate in sec of token User (metadata)
     */
    function mint(address mintAddress, string memory name, uint256 gender, uint256 birthdayDate) external payable;

    /**
     * @notice Free mint LifeSpan token for staffers
     * @param mintAddress where to enroll the LifeSpan token after minting
     * @param name of token User (metadata)
     * @param gender of token User (metadata)
     * @param birthdayDate in sec of token User (metadata)
     */
    function freeMint(address mintAddress, string memory name, uint256 gender, uint256 birthdayDate) external;

    /**
     * @notice Withdraw mint fee on feeAddress
     * @param amount withdraw amount
     */
    function withdraw(uint256 amount) external;

    /// @notice Emitted when LifeSpan token has been minted
    event TokenMinted(
        address indexed purchaser,
        address indexed recipient,
        uint256 amount
    );

    /// @notice Emitted when LifeSpan token has been minted by user with STAFF role
    event TokenFreeMinted(address indexed staffer, address indexed recipient);

    /// @notice Emitted when LifeSpan token mint price has been changed
    event MintPriceChanged(uint256 newPrice);

    /// @notice Emitted when feee address has been changed
    event FeeAddressChanged(address indexed feeAddress);

    /// @notice Emitted when LifeSpan contract address has been changed
    event LifeSpanAddressChanged(address indexed lifeSpanAddress);

    /// @notice Emitted when was the fee withdrawn
    event FeeWithdrawn(uint256 amount, address indexed feeAddress);
}
