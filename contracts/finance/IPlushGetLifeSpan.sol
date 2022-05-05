// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IPlushGetLifeSpan {


    /// @notice Emitted when LifeSpan token has been minted
    event TokenMinted(
        address indexed purchaser,
        address indexed recipient,
        uint256 amount
    );

    /// @notice Emitted when LifeSpan token has been minted by user with STAFF role
    event TokenFreeMinted(
        address indexed staffer,
        address indexed recipient
    );

}