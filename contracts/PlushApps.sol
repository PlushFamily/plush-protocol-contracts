// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "./IPlushApps.sol";

/// @custom:security-contact security@plush.family
contract PlushApps is Initializable, PausableUpgradeable, AccessControlUpgradeable, UUPSUpgradeable, IPlushApps {
    mapping(address => Apps) public appsList;

    /**
     * @dev Roles definitions
     */
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize() initializer public {
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
    function addNewApp(bytes32 name, address controllerAddress, uint256 fee) external onlyRole(OPERATOR_ROLE) {
        require(!appsList[controllerAddress].exists, "Application already exists");

        appsList[controllerAddress] = Apps(name, fee, true, true);

        emit AppAdded(name, controllerAddress, fee);
    }

    /**
     * @notice Delete app from PlushApps
     * @param controllerAddress App controller address
     */
    function deleteApp(address controllerAddress) external onlyRole(OPERATOR_ROLE) {
        require(appsList[controllerAddress].exists, "Application doesn't exist");

        delete appsList[controllerAddress];

        emit AppDeleted(controllerAddress);
    }

    /**
     * @notice Get app fee
     * @param controllerAddress controller address
     * @return App fee
     */
    function getFeeApp(address controllerAddress) public view returns(uint256) {
        require(appsList[controllerAddress].exists, "Application doesn't exist");

        return appsList[controllerAddress].fee;
    }

    /**
     * @notice Change fee app
     * @param controllerAddress App controller address
     * @param fee App ecosystem fee in wei
     */
    function setFeeApp(address controllerAddress, uint256 fee) external onlyRole(OPERATOR_ROLE) {
        require(appsList[controllerAddress].exists, "Application doesn't exist");

        appsList[controllerAddress].fee = fee;

        emit AppFeeChanged(controllerAddress, fee);
    }

    /**
     * @notice Activating the application
     * @param controllerAddress App controller address
     */
    function setAppEnable(address controllerAddress) external onlyRole(OPERATOR_ROLE) {
        require(appsList[controllerAddress].exists, "Application doesn't exist");
        require(!appsList[controllerAddress].active, "Application already enable");

        appsList[controllerAddress].active = true;

        emit AppEnabled(controllerAddress);
    }

    /**
     * @notice Disabling the application
     * @param controllerAddress App controller address
     */
    function setAppDisable(address controllerAddress) external onlyRole(OPERATOR_ROLE) {
        require(appsList[controllerAddress].exists, "Application doesn't exist");
        require(appsList[controllerAddress].active, "Application already disable");

        appsList[controllerAddress].active = false;

        emit AppDisabled(controllerAddress);
    }

    /**
     * @notice Update application controller address
     * @param oldControllerAddress exist controller application address
     * @param newControllerAddress new controller application address
     */
    function setNewController(address oldControllerAddress, address newControllerAddress) external onlyRole(OPERATOR_ROLE) {
        require(appsList[oldControllerAddress].exists, "Application doesn't exist");
        require(!appsList[newControllerAddress].exists, "New controller address is already in use");

        appsList[newControllerAddress] = appsList[oldControllerAddress];
        delete appsList[oldControllerAddress];

        emit AppControllerAddressUpdated(oldControllerAddress, newControllerAddress);
    }

    /**
     * @notice Get app status (enable/disable)
     * @param controllerAddress app controller address
     * @return app enable status in boolean
     */
    function getAppStatus(address controllerAddress) public view returns(bool) {
        require(appsList[controllerAddress].exists, "Application doesn't exist");

        return appsList[controllerAddress].active;
    }

    function _authorizeUpgrade(address newImplementation)
    internal
    onlyRole(UPGRADER_ROLE)
    override
    {}
}