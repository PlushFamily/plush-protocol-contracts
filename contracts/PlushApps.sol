// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/// @custom:security-contact security@plush.family
contract PlushApps is Initializable, PausableUpgradeable, AccessControlUpgradeable, UUPSUpgradeable {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    struct Apps
    {
        string name;
        bool active;
        bool created;
        uint256 fee;
    }

    mapping(address => Apps) public appsInfo;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize() public initializer
    {
        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(OPERATOR_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
    }

    function pause() public onlyRole(PAUSER_ROLE)
    {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE)
    {
        _unpause();
    }

    function deleteApp(address _controllerAddress) public onlyRole(OPERATOR_ROLE)
    {
        require(isInStruct(_controllerAddress), "There is no such application.");

        delete appsInfo[_controllerAddress];
    }

    function addNewApp(string memory _name, address _controllerAddress, uint256 _fee) external onlyRole(OPERATOR_ROLE)
    {
        require(isInStruct(_controllerAddress) == false, "Application already exists.");

        appsInfo[_controllerAddress].name = _name;
        appsInfo[_controllerAddress].active = true;
        appsInfo[_controllerAddress].created = true;
        appsInfo[_controllerAddress].fee = _fee;
    }

    function getFeeApp(address _controllerAddress) public view returns(uint256)
    {
        require(isInStruct(_controllerAddress), "There is no such application.");

        return appsInfo[_controllerAddress].fee;
    }

    function setFeeApp(address _controllerAddress, uint256 _fee) external onlyRole(OPERATOR_ROLE)
    {
        require(isInStruct(_controllerAddress), "There is no such application.");
        appsInfo[_controllerAddress].fee = _fee;
    }

    function setIsActive(bool _isActive, address _controllerAddress ) external onlyRole(OPERATOR_ROLE)
    {
        require(isInStruct(_controllerAddress), "There is no such application.");

        appsInfo[_controllerAddress].active = _isActive;
    }

    function setNewController(address _oldControllerAddress, address _newControllerAddress) external onlyRole(OPERATOR_ROLE)
    {
        require(isInStruct(_oldControllerAddress), "There is no such application.");

        appsInfo[_newControllerAddress] = appsInfo[_oldControllerAddress];
        deleteApp(_oldControllerAddress);
    }

    function isInStruct(address _controllerAddress) private view returns(bool)
    {
        if(appsInfo[_controllerAddress].created){
            return true;
        }

        return false;
    }

    function getIsAddressActive(address _controllerAddress) public view returns(bool)
    {
        require(isInStruct(_controllerAddress), "There is no such application.");

        return appsInfo[_controllerAddress].active;
    }

    function _authorizeUpgrade(address newImplementation)
    internal
    onlyRole(UPGRADER_ROLE)
    override
    {}
}