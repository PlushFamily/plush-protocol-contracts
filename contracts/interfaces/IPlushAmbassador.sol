// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IPlushAmbassador {
    /**
     * @notice Set new token URI link
     * @param newuri URI
     */
    function setURI(string memory newuri) external;

    /**
     * @notice Mint Ambassador NFT
     * @param account recipient wallet
     * @param id token Id
     * @param amount token mint amount
     * @param data token data
     */
    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external;

    /**
     * @notice Mint a batch of Ambassador NFT
     * @param to recipient wallet
     * @param ids token Ids
     * @param amounts token mint amount
     * @param data token data
     */
    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) external;

    /**
     * @notice Set new contract URI
     * @param _contractURI new contract URI
     */
    function setContractURI(string memory _contractURI) external;
}
