// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../../interfaces/ILifeSpan.sol";

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

/// @custom:security-contact security@plush.family
contract LifeSpan is ILifeSpan, Initializable, ERC721Upgradeable, ERC721EnumerableUpgradeable, PausableUpgradeable, AccessControlUpgradeable, ERC721BurnableUpgradeable, UUPSUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using Strings for uint256;

    CountersUpgradeable.Counter private _tokenIdCounter;

    /**
     * @dev Roles definitions
     */
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    mapping(uint256 => MetaData) private metaData;
    mapping(uint256 => Gender) private genders;

    string externalUrl;
    string generatorImageUrl;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize(
        string memory extUrl,
        string memory genImageUrl
    ) initializer public
    {
        __ERC721_init("LifeSpan", "LIFESPAN");
        __ERC721Enumerable_init();
        __Pausable_init();
        __AccessControl_init();
        __ERC721Burnable_init();
        __UUPSUpgradeable_init();

        externalUrl = extUrl;
        generatorImageUrl = genImageUrl;

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
        _grantRole(OPERATOR_ROLE, msg.sender);
    }

    /// @notice Pause contract
    function pause()
    public
    onlyRole(PAUSER_ROLE)
    {
        _pause();
    }

    /// @notice Unpause contract
    function unpause()
    public
    onlyRole(PAUSER_ROLE)
    {
        _unpause();
    }

    /**
     * @notice Safe mint LifeSpan token
     * @param to wallet address to which the token is mint
     * @param name of LifeSpan token
     * @param gender id of LifeSpan token
     * @param birthdayDate time in sec when the token(user) was born
     */
    function safeMint(address to, string memory name, uint256 gender, uint256 birthdayDate)
    public
    onlyRole(MINTER_ROLE)
    {
        require(bytes(genders[gender].name).length != 0, "ERC721Metadata: Gender not exists");
        require(genders[gender].isActive, "ERC721Metadata: Gender not active");

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        metaData[tokenId] = MetaData(name, gender, birthdayDate);
    }

    /**
     * @notice Get base section of LifeSpan token in json
     * @param tokenId id LifeSpan token
     * @return bytes(json) of base section
     */
    function baseSection(uint256 tokenId)
    internal
    view
    returns (bytes memory)
    {
        bytes memory base = abi.encodePacked(
            '{',
            '"description":"Plush ecosystem avatar",',
            '"external_url": "', externalUrl, tokenId.toString(), '",',
            '"name": "', metaData[tokenId].name, '",',
            '"image":"', generatorImageUrl, '",'
        );

        return base;
    }

    /**
     * @notice Get attributes of LifeSpan token in json
     * @param tokenId id LifeSpan token
     * @return bytes(json) of attributes
     */
    function attributesSection(uint256 tokenId)
    internal
    view
    returns (bytes memory)
    {
        bytes memory atr = abi.encodePacked(
            '"attributes":',
            '[{',
            '"display_type":"date","trait_type":"birthday","value":"', metaData[tokenId].birthdayDate.toString(),
                '?age=', metaData[tokenId].birthdayDate,
                '&name=', metaData[tokenId].name,
                '&gender=', metaData[tokenId].gender,
            '"',
            '},{',
            '"trait_type":"Gender","value":"', genders[metaData[tokenId].gender].name, '"',
            '}]',
            '}'
        );

        return atr;
    }

    /**
     * @notice Add new gender
     * @param id of new gender
     * @param newGender name of new gender
     */
    function addGender(uint256 id, string memory newGender)
    public
    onlyRole(OPERATOR_ROLE)
    {
        require(bytes(genders[id].name).length == 0, "ERC721Metadata: Gender already exists");

        genders[id].name = newGender;
        genders[id].isActive = true;
    }

    /**
     * @notice Enable or disable gender
     * @param id of gender
     * @param isActive true or false
     */
    function setIsActiveGender(uint256 id, bool isActive)
    public
    onlyRole(OPERATOR_ROLE)
    {
        require(bytes(genders[id].name).length != 0, "ERC721Metadata: Gender not exists");

        genders[id].isActive = isActive;
    }

    /**
     * @notice Change name of LifeSpan token
     * @param tokenId id LifeSpan token
     * @param newName new name of LifeSpan token
     */
    function updateName(uint256 tokenId, string memory newName)
    public
    {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        require(ownerOf(tokenId) == msg.sender, "ERC721: you are not the owner of the token");

        metaData[tokenId].name = newName;
    }

    /**
     * @notice Change gender of LifeSpan token
     * @param tokenId id LifeSpan token
     * @param newGender id new gender of LifeSpan token
     */
    function updateGender(uint256 tokenId, uint256 newGender)
    public
    {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        require(ownerOf(tokenId) == msg.sender, "ERC721: you are not the owner of the token");
        require(bytes(genders[newGender].name).length != 0, "ERC721Metadata: Gender not exists");
        require(genders[newGender].isActive, "ERC721Metadata: Gender not active");

        metaData[tokenId].gender = newGender;
    }

    /**
     * @notice Update external url LifeSpan
     * @param newExternalUrl sting of new link
     */
    function updateExternalUrl(string memory newExternalUrl)
    public
    onlyRole(OPERATOR_ROLE)
    {
        externalUrl = newExternalUrl;
    }

    /**
     * @notice Update generator images LifeSpan
     * @param newGeneratorIMGUrl sting of new link
     */
    function updateGeneratorIMGUrl(string memory newGeneratorIMGUrl)
    public
    onlyRole(OPERATOR_ROLE)
    {
        generatorImageUrl = newGeneratorIMGUrl;
    }

    /**
     * @notice Get dynamic token URI
     * @param tokenId id LifeSpan token
     * @return base64(json) data of LifeSpan
     */
    function tokenURI(uint256 tokenId)
    public
    view
    override
    returns (string memory)
    {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        bytes memory base = baseSection(tokenId);
        bytes memory atr = attributesSection(tokenId);
        bytes memory dataURI = abi.encodePacked(base, atr);

        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(dataURI)));
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
    internal
    whenNotPaused
    override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
    public
    view
    override(ERC721Upgradeable, ERC721EnumerableUpgradeable, AccessControlUpgradeable)
    returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _authorizeUpgrade(address newImplementation)
    internal
    onlyRole(UPGRADER_ROLE)
    override
    {}
}
