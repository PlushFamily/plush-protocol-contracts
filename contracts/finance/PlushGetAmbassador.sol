// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../interfaces/IPlushGetAmbassador.sol";

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "../token/ERC1155/PlushAmbassador.sol";

/// @custom:security-contact security@plush.family
contract PlushGetAmbassador is
IPlushGetAmbassador,
Initializable,
AccessControlUpgradeable,
UUPSUpgradeable
{
    PlushAmbassador public plushAmbassador;

    mapping(uint256 => Token) public tokens;

    /**
     * @dev Roles definitions
     */
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        PlushAmbassador _plushAmbassador
    ) public initializer {
        plushAmbassador = _plushAmbassador;

        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(OPERATOR_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
    }

    function _authorizeUpgrade(address newImplementation)
    internal
    override
    onlyRole(UPGRADER_ROLE)
    {}
}