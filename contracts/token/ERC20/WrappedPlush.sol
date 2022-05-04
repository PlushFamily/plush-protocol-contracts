// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Wrapper.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

/// @custom:security-contact security@plush.family
contract WrappedPlush is ERC20, ERC20Permit, ERC20Votes, ERC20Wrapper, ERC20Burnable {
    constructor(IERC20 wrappedToken)
    ERC20("wPlush", "wPLSH")
    ERC20Permit("WPlush")
    ERC20Wrapper(wrappedToken)
    {}

    function _afterTokenTransfer(address from, address to, uint256 amount)
    internal
    override(ERC20, ERC20Votes)
    {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount)
    internal
    override(ERC20, ERC20Votes)
    {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount)
    internal
    override(ERC20, ERC20Votes)
    {
        super._burn(account, amount);
    }

    function decimals() public view virtual override(ERC20, ERC20Wrapper) returns (uint8) {
        return super.decimals();
    }
}
