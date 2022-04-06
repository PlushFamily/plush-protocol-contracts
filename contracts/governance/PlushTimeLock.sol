// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/governance/TimelockControllerUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

contract PlushTimeLock is Initializable, TimelockControllerUpgradeable, UUPSUpgradeable, OwnableUpgradeable  {
  /// @custom:oz-upgrades-unsafe-allow constructor
  constructor() initializer {}

  function initialize (uint256 minDelay, address[] memory proposers, address[] memory executors) initializer public
  {
    __UUPSUpgradeable_init();
    __TimelockController_init(minDelay, proposers, executors);
  }

  function _authorizeUpgrade(address newImplementation) internal onlyOwner override
  {}
}