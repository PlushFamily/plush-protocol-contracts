// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./PlushForestToken.sol";

contract PlushGetTree is Ownable {

    bool public isActive = true;
    uint256 public price = 0.001 ether;

    function mint(PlushForestToken _callee, address to) public payable {
        require(isActive);
        require(msg.value == price, "Minting fee");
        _callee.safeMint(to);
    }

    function changeContractStatus() public onlyOwner {
        isActive = !isActive;
    }

    function changePrice(uint256 newPrice) public onlyOwner {
        require(isActive);
        require(newPrice > 0);
        price = newPrice;
    }
}