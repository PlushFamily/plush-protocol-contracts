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

    /**
     * @notice Add new app to PlushApps
     * @param name App name in bytes32
     * @param controllerAddress App controller address
     * @param fee App ecosystem fee in wei
     */
    function addNewApp(
        bytes32 name,
        address controllerAddress,
        uint256 fee
    ) external;

    /**
     * @notice Check if the application exists
     * @param controllerAddress App controller address
     * @return boolean exists status
     */
    function getAppExists(address controllerAddress)
        external
        view
        returns (bool);

    /**
     * @notice Delete app from PlushApps
     * @param controllerAddress App controller address
     */
    function deleteApp(address controllerAddress) external;

    /**
     * @notice Get app fee
     * @param controllerAddress controller address
     * @return App fee
     */
    function getFeeApp(address controllerAddress)
        external
        view
        returns (uint256);

    /**
     * @notice Change fee app
     * @param controllerAddress App controller address
     * @param fee App ecosystem fee in wei
     */
    function setFeeApp(address controllerAddress, uint256 fee) external;

    /**
     * @notice Activating the application
     * @param controllerAddress App controller address
     */
    function setAppEnable(address controllerAddress) external;

    /**
     * @notice Disabling the application
     * @param controllerAddress App controller address
     */
    function setAppDisable(address controllerAddress) external;

    /**
     * @notice Update application controller address
     * @param oldControllerAddress exist controller application address
     * @param newControllerAddress new controller application address
     */
    function setNewController(
        address oldControllerAddress,
        address newControllerAddress
    ) external;

    /**
     * @notice Get app status (enable/disable)
     * @param controllerAddress app controller address
     * @return app enable status in boolean
     */
    function getAppStatus(address controllerAddress)
        external
        view
        returns (bool);

    /// @notice Emitted when app is added
    event AppAdded(
        bytes32 name,
        address indexed controllerAddress,
        uint256 fee
    );

    /// @notice Emitted when app has been deleted
    event AppDeleted(address indexed controllerAddress);

    /// @notice Emitted when app fee was changed
    event AppFeeChanged(address indexed controllerAddress, uint256 fee);

    /// @notice Emitted when enable app
    event AppEnabled(address indexed controllerAddress);

    /// @notice Emitted when disable app
    event AppDisabled(address indexed controllerAddress);

    /// @notice Emitted changed controlled address
    event AppControllerAddressUpdated(
        address indexed oldControllerAddress,
        address indexed newControllerAddress
    );
}
