// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";

contract PlushApps is Ownable {

    struct Apps
    {
        string name;
        bool active;
        bool created;
        uint256 fee;
    }

    mapping(address => Apps) public appsInfo;

    function deleteApp(address _controllerAddress) public onlyOwner
    {
        require(isInStruct(_controllerAddress), "There is no such application.");

        delete appsInfo[_controllerAddress];
    }

    function addNewApp(string memory _name, address _controllerAddress, uint256 _fee) external onlyOwner
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

    function setFeeApp(address _controllerAddress, uint256 _fee) external onlyOwner
    {
        require(isInStruct(_controllerAddress), "There is no such application.");
        appsInfo[_controllerAddress].fee = _fee;
    }

    function setIsActive(bool _isActive, address _controllerAddress ) external onlyOwner
    {
        require(isInStruct(_controllerAddress), "There is no such application.");

        appsInfo[_controllerAddress].active = _isActive;
    }

    function setNewController(address _oldControllerAddress, address _newControllerAddress) external onlyOwner
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
}