// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./PlushCoreToken.sol";

/// @custom:security-contact security@plush.family


contract PlushGetCoreToken is Ownable {

    PlushCoreToken plushCoreToken;
    address  payable safeAddress;
    uint256 mintPrice;
    bool public tokenNFTCheck;
    bool public isActive;

    constructor(address _plushCoreAddress, address _safeAddress)
    {
        plushCoreToken = PlushCoreToken(_plushCoreAddress);
        safeAddress = payable(_safeAddress);
        mintPrice = 0.001 ether;
        tokenNFTCheck = true;
        isActive = true;
    }

    function pause() public onlyOwner {
        isActive = !isActive;
    }

    function changeTokenCheckStatus() public onlyOwner {
        require(isActive, "Contract is not active");
        tokenNFTCheck = !tokenNFTCheck;
    }

    function changeMintPrice(uint256 _price) public onlyOwner {
        require(isActive, "Contract is not active");
        mintPrice = _price;
    }

    function getMintPrice() external view returns(uint256) {
        return mintPrice;
    }

    function setSafeAddress(address _address) external onlyOwner {
        safeAddress = payable(_address);
    }

    function setCoreTokenAddress(address _address) external onlyOwner {
        plushCoreToken = PlushCoreToken(_address);
    }

    function getSafeAddress() external view onlyOwner returns(address) {
        return safeAddress;
    }

    function getCoreTokenAddress() external view onlyOwner returns(address) {
        return address(plushCoreToken);
    }

    function mint(address _mintAddress) public payable{
        require(isActive, "Contract is not active");
        require(uint256(msg.value) == mintPrice, "Incorrect amount");

        if(tokenNFTCheck){
            require(plushCoreToken.balanceOf(_mintAddress) == 0, "You already have a Core token");
        }

        safeAddress.transfer(msg.value);
        plushCoreToken.safeMint(_mintAddress);
    }

}