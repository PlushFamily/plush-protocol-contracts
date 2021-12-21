// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";

/// @custom:security-contact security@plush.family
contract PlushCoin is ERC20, ERC20Burnable, ERC20Permit {
    constructor() ERC20("PlushCoin", "PLSH") ERC20Permit("PlushCoin") {
        _mint(msg.sender, 10000000000 * 10 ** decimals());
    }
}