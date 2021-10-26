// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./PlushForestToken.sol";

contract PlushGetTree is Ownable {

    PlushForestToken plushForest;
    bool public isActive;
    address safeAddress;
    uint256 mintPrice;

    constructor(address _plushForestAddress, address _safeAddress)
    {
        isActive = true;
        mintPrice = 0.001 ether;
        plushForest = PlushForestToken(_plushForestAddress);
        safeAddress = _safeAddress;
    }

    function setSafeAddress(address _address) external onlyOwner {
        safeAddress = _address;
    }

    function getSafeAddress() external view onlyOwner returns(address) {
        return safeAddress;
    }

    function getMintPrice() external view returns(uint) {
        return mintPrice;
    }

    function setMintPrice(uint256 _price) external onlyOwner {
        require(isActive);
        require(_price > 0);
        mintPrice = _price;
    }

    function mint(address mintAddress)public payable {
        require(isActive);
        require(msg.value == mintPrice, "Minting fee");
        plushForest.safeMint(mintAddress);
    }

    function changeContractStatus() public onlyOwner {
        isActive = !isActive;
    }
}