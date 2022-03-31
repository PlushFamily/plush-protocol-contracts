// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/governance/GovernorUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorSettingsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorCountingSimpleUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorVotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorVotesQuorumFractionUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorTimelockControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "../token/ERC721/PlushCoreToken.sol";

/// @custom:security-contact security@plush.family
contract PlushOperationsDAO is Initializable, GovernorUpgradeable, GovernorSettingsUpgradeable, GovernorCountingSimpleUpgradeable, GovernorVotesUpgradeable, GovernorVotesQuorumFractionUpgradeable, GovernorTimelockControlUpgradeable, OwnableUpgradeable, UUPSUpgradeable {
  PlushCoreToken public plushCoreToken;

  /// @custom:oz-upgrades-unsafe-allow constructor
  constructor() initializer {}

  function initialize(IVotesUpgradeable _token, PlushCoreToken _tokenCore, TimelockControllerUpgradeable _timelock) public initializer
  {
    __Governor_init("PlushOperationsDAO");
    __GovernorSettings_init(1 /* 1 block */, 19636 /* 3 days */, 1e18);
    __GovernorCountingSimple_init();
    __GovernorVotes_init(_token);
    __GovernorVotesQuorumFraction_init(1);
    __GovernorTimelockControl_init(_timelock);
    __Ownable_init();
    __UUPSUpgradeable_init();
    plushCoreToken = _tokenCore;
  }

  function _authorizeUpgrade(address newImplementation) internal onlyOwner override
  {}

  // The following functions are overrides required by Solidity.

  function votingDelay() public view override(IGovernorUpgradeable, GovernorSettingsUpgradeable) returns (uint256)
  {
    return super.votingDelay();
  }

  function votingPeriod() public view override(IGovernorUpgradeable, GovernorSettingsUpgradeable) returns (uint256)
  {
    return super.votingPeriod();
  }

  function quorum(uint256 blockNumber) public view override(IGovernorUpgradeable, GovernorVotesQuorumFractionUpgradeable) returns (uint256)
  {
    return super.quorum(blockNumber);
  }

  function getVotes(address account, uint256 blockNumber) public view override(IGovernorUpgradeable, GovernorVotesUpgradeable) returns (uint256)
  {
    if(plushCoreToken.balanceOf(account) > 0){
      return super.getVotes(account, blockNumber);
    }

    return 0;
  }

  function state(uint256 proposalId) public view override(GovernorUpgradeable, GovernorTimelockControlUpgradeable) returns (ProposalState)
  {
    return super.state(proposalId);
  }

  function propose(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, string memory description) public override(GovernorUpgradeable, IGovernorUpgradeable) returns (uint256)
  {
    return super.propose(targets, values, calldatas, description);
  }

  function proposalThreshold() public view override(GovernorUpgradeable, GovernorSettingsUpgradeable) returns (uint256)
  {
    return super.proposalThreshold();
  }

  function _execute(uint256 proposalId, address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash) internal override(GovernorUpgradeable, GovernorTimelockControlUpgradeable)
  {
    super._execute(proposalId, targets, values, calldatas, descriptionHash);
  }

  function _cancel(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash) internal override(GovernorUpgradeable, GovernorTimelockControlUpgradeable) returns (uint256)
  {
    return super._cancel(targets, values, calldatas, descriptionHash);
  }

  function _executor() internal view override(GovernorUpgradeable, GovernorTimelockControlUpgradeable) returns (address)
  {
    return super._executor();
  }

  function supportsInterface(bytes4 interfaceId) public view override(GovernorUpgradeable, GovernorTimelockControlUpgradeable) returns (bool)
  {
    return super.supportsInterface(interfaceId);
  }
}