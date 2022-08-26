// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IPlushGetAmbassador {
    struct Token {
        uint256 id;
        bool active;
        bool exists;
    }

    /**
     * @notice Mint PlushAmbassador token
     * @param token tokenId for minting
     */
    function mint(uint256 token) external;

    /**
     * @notice Add new token
     * @param token tokenId for minting
     */
    function addNewToken(uint256 token) external;

    /**
     * @notice Enable token minting
     * @param token tokenId for minting
     */
    function enableTokenMinting(uint256 token) external;

    /**
     * @notice Disable token minting
     * @param token tokenId for minting
     */
    function disableTokenMinting(uint256 token) external;

    /// @notice Emitted when PlushAmbassador token has been minted
    event TokenMinted(address indexed recipient, uint256 token);

    /// @notice Emitted when new PlushAmbassador token has been added
    event TokenAdded(uint256 token);

    /// @notice Emitted when minting of PlushAmbassador token has been enable
    event TokenMintingEnable(uint256 token);

    /// @notice Emitted when minting of PlushAmbassador token has been disable
    event TokenMintingDisable(uint256 token);
}
