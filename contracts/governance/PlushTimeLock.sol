// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/governance/TimelockControllerUpgradeable.sol";

contract PlushTimeLock is TimelockControllerUpgradeable {
  function initialize (uint256 minDelay, address[] memory proposers, address[] memory executors) initializer public
  {
    __TimelockController_init(minDelay, proposers, executors);
  }
}