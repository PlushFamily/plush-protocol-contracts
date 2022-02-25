// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";

contract PlushApps is Ownable {

    struct Apps
    {
        string name;
        bool active;
        address controllerAddress;
        bool created;
        uint256 fee;
    }

    mapping(address => Apps) public appsInfo;

    function deleteApp(address _appAddress) external onlyOwner
    {
        require(isInStruct(_appAddress), "There is no such application.");

        delete appsInfo[_appAddress];
    }

    function addNewApp(string memory _name, address _appAddress, address _controllerAddress, uint256 _fee) external onlyOwner
    {
        require(isInStruct(_appAddress) == false, "Application already exists.");

        appsInfo[_appAddress].name = _name;
        appsInfo[_appAddress].active = true;
        appsInfo[_appAddress].created = true;
        appsInfo[_appAddress].controllerAddress = _controllerAddress;
        appsInfo[_appAddress].fee = _fee;
    }

    function getFeeApp(address _appAddress) public view returns(uint256)
    {
        require(isInStruct(_appAddress), "There is no such application.");

        return appsInfo[_appAddress].fee;
    }

    function setFeeApp(address _appAddress, uint256 _fee) external onlyOwner
    {
        require(isInStruct(_appAddress), "There is no such application.");
        appsInfo[_appAddress].fee = _fee;
    }

    function setIsActive(bool _isActive, address _appAddress ) external onlyOwner
    {
        require(isInStruct(_appAddress), "There is no such application.");

        appsInfo[_appAddress].active = _isActive;
    }

    function isInStruct(address _appAddress) private view returns(bool)
    {
        if(appsInfo[_appAddress].created){
            return true;
        }

        return false;
    }

    function getIsAddressActive(address _appAddress) public view returns(bool)
    {
        require(isInStruct(_appAddress), "There is no such application.");

        return appsInfo[_appAddress].active;
    }

    function getControllerAddress(address _appAddress) public view returns(address)
    {
        require(isInStruct(_appAddress), "There is no such application.");

        return appsInfo[_appAddress].controllerAddress;
    }
}