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
    mapping(address => bool) public applicants;

    /**
     * @dev Roles definitions
     */
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(PlushAmbassador _plushAmbassador) public initializer {
        plushAmbassador = _plushAmbassador;

        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(OPERATOR_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
    }

    /**
     * @notice Mint PlushAmbassador token
     * @param token tokenId for minting
     */
    function mint(uint256 token) public {
        require(tokens[token].exists, "Token doesn't exist");
        require(tokens[token].active, "Token doesn't active");

        require(!applicants[msg.sender], "You can't mint twice");

        applicants[msg.sender] = true;

        plushAmbassador.mint(msg.sender, token, 1, "");

        emit TokenMinted(msg.sender, token);
    }

    /**
     * @notice Check the possibility of minting a token for a specific address
     * @param applicant recipient's address
     */
    function checkMintPossibility(address applicant)
        public
        view
        returns (bool)
    {
        if (applicants[applicant]) {
            return false;
        }

        return true;
    }

    /**
     * @notice Add new token
     * @param token tokenId for minting
     */
    function addNewToken(uint256 token) external onlyRole(OPERATOR_ROLE) {
        require(!tokens[token].exists, "Token already exists");

        tokens[token] = Token(token, true, true);

        emit TokenAdded(token);
    }

    /**
     * @notice Enable token minting
     * @param token tokenId for minting
     */
    function enableTokenMinting(uint256 token)
        external
        onlyRole(OPERATOR_ROLE)
    {
        require(tokens[token].exists, "Token doesn't exist");
        require(!tokens[token].active, "Token minting already active");

        tokens[token].active = true;

        emit TokenMintingEnable(token);
    }

    /**
     * @notice Disable token minting
     * @param token tokenId for minting
     */
    function disableTokenMinting(uint256 token)
        external
        onlyRole(OPERATOR_ROLE)
    {
        require(tokens[token].exists, "Token doesn't exist");
        require(tokens[token].active, "Token minting already disable");

        tokens[token].active = false;

        emit TokenMintingDisable(token);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(UPGRADER_ROLE)
    {}
}
