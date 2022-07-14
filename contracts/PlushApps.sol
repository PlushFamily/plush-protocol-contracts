// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./interfaces/IPlushApps.sol";

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/// @custom:security-contact security@plush.family
contract PlushApps is
    IPlushApps,
    Initializable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    mapping(address => Apps) public appsList;

    /**
     * @dev Roles definitions
     */
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(OPERATOR_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
    }

    /// @notice Pause contract
    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /// @notice Unpause contract
    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

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
    ) external onlyRole(OPERATOR_ROLE) {
        require(
            !appsList[controllerAddress].exists,
            "Application already exists"
        );

        appsList[controllerAddress] = Apps(name, fee, true, true);

        emit AppAdded(name, controllerAddress, fee);
    }

    /**
     * @notice Check if the application exists
     * @param controllerAddress App controller address
     * @return boolean exists status
     */
    function getAppExists(address controllerAddress)
        public
        view
        returns (bool)
    {
        if (appsList[controllerAddress].exists) {
            return true;
        }

        return false;
    }

    /**
     * @notice Get app status (enable/disable)
     * @param controllerAddress app controller address
     * @return app enable status in boolean
     */
    function getAppStatus(address controllerAddress)
        public
        view
        returns (bool)
    {
        require(
            appsList[controllerAddress].exists,
            "Application doesn't exist"
        );

        return appsList[controllerAddress].active;
    }

    /**
     * @notice Delete app from PlushApps
     * @param controllerAddress App controller address
     */
    function deleteApp(address controllerAddress)
        external
        onlyRole(OPERATOR_ROLE)
    {
        require(
            appsList[controllerAddress].exists,
            "Application doesn't exist"
        );

        delete appsList[controllerAddress];

        emit AppDeleted(controllerAddress);
    }

    /**
     * @notice Get app fee
     * @param controllerAddress controller address
     * @return App fee
     */
    function getFeeApp(address controllerAddress)
        public
        view
        returns (uint256)
    {
        require(
            appsList[controllerAddress].exists,
            "Application doesn't exist"
        );

        return appsList[controllerAddress].fee;
    }

    /**
     * @notice Change fee app
     * @param controllerAddress App controller address
     * @param fee App ecosystem fee in wei
     */
    function setFeeApp(address controllerAddress, uint256 fee)
        external
        onlyRole(OPERATOR_ROLE)
    {
        require(
            appsList[controllerAddress].exists,
            "Application doesn't exist"
        );

        appsList[controllerAddress].fee = fee;

        emit AppFeeChanged(controllerAddress, fee);
    }

    /**
     * @notice Activating the application
     * @param controllerAddress App controller address
     */
    function setAppEnable(address controllerAddress)
        external
        onlyRole(OPERATOR_ROLE)
    {
        require(
            appsList[controllerAddress].exists,
            "Application doesn't exist"
        );
        require(
            !appsList[controllerAddress].active,
            "Application already enable"
        );

        appsList[controllerAddress].active = true;

        emit AppEnabled(controllerAddress);
    }

    /**
     * @notice Disabling the application
     * @param controllerAddress App controller address
     */
    function setAppDisable(address controllerAddress)
        external
        onlyRole(OPERATOR_ROLE)
    {
        require(
            appsList[controllerAddress].exists,
            "Application doesn't exist"
        );
        require(
            appsList[controllerAddress].active,
            "Application already disable"
        );

        appsList[controllerAddress].active = false;

        emit AppDisabled(controllerAddress);
    }

    /**
     * @notice Update application controller address
     * @param oldControllerAddress exist controller application address
     * @param newControllerAddress new controller application address
     */
    function setNewController(
        address oldControllerAddress,
        address newControllerAddress
    ) external onlyRole(OPERATOR_ROLE) {
        require(
            appsList[oldControllerAddress].exists,
            "Application doesn't exist"
        );
        require(
            !appsList[newControllerAddress].exists,
            "New controller address is already in use"
        );

        appsList[newControllerAddress] = appsList[oldControllerAddress];
        delete appsList[oldControllerAddress];

        emit AppControllerAddressUpdated(
            oldControllerAddress,
            newControllerAddress
        );
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(UPGRADER_ROLE)
    {}
}
