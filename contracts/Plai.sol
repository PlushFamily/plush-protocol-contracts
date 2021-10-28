// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @custom:security-contact hello@plush.family
contract Plai is ERC20 {
    constructor() ERC20("Plai", "PLAI") {
        _mint(msg.sender, 1000000000 * 10 ** decimals());
    }
}