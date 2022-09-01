// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IPlushGetLifeSpan {
    /// @notice Pause contract
    function pause() external;

    /// @notice Unpause contract
    function unpause() external;

    /**
     * @notice Change mint price
     * @param _newPrice new price
     */
    function changeMintPrice(uint256 _newPrice) external;

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
     * @notice Mint LifeSpan token
     * @param _mintAddress where to enroll the LifeSpan token after minting
     * @param _name of token User (metadata)
     * @param _gender of token User (metadata)
     * @param _birthdayDate in sec of token User (metadata)
     */
    function mint(
        address _mintAddress,
        string memory _name,
        uint256 _gender,
        uint256 _birthdayDate
    ) external payable;

    /**
     * @notice Free mint LifeSpan token for staffers
     * @param _mintAddress where to enroll the LifeSpan token after minting
     * @param _name of token User (metadata)
     * @param _gender of token User (metadata)
     * @param _birthdayDate in sec of token User (metadata)
     */
    function freeMint(
        address _mintAddress,
        string memory _name,
        uint256 _gender,
        uint256 _birthdayDate
    ) external;

    /**
     * @notice Withdraw mint fee on feeAddress
     * @param _amount withdraw amount
     */
    function withdraw(uint256 _amount) external;

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
