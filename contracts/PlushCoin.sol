// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @custom:security-contact security@plush.family
contract PlushCoin is ERC20 {
    constructor() ERC20("Plush Coin", "PLSH") {
        _mint(msg.sender, 10000000000 * 10 ** decimals());
    }
}