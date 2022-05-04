// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IPlushApps {

    struct Apps {
        bytes32 name;
        uint256 fee;
        bool active;
        bool exists;
    }

    /// @notice Pause contract
    function pause() external;

    /// @notice Unpause contract
    function unpause() external;

}