// SPDX-License-Identifier: MIT
// Plush Forest Token v1
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract PlushForestTokenV1 is ERC1155 {
    uint256 public constant CACAO = 0;
    uint256 public constant CHIHUAHUA = 1;
    uint256 public constant GUAYABA = 2;
    uint256 public constant CAOBA = 3;

    constructor() ERC1155("https://api.plush.dev/token/forest/{id}.json") {
        _mint(msg.sender, CACAO, 590, "");
        _mint(msg.sender, CHIHUAHUA, 343, "");
        _mint(msg.sender, GUAYABA, 58, "");
        _mint(msg.sender, CAOBA, 7, "");
    }
}