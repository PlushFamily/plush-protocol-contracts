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

    mapping(uint256 => TokenData) public tokenData;
    mapping(uint256 => Gender) private genders;

    string externalURL;
    string renderImageURL;

    /**
     * @dev Roles definitions
     */
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize(
        string memory _externalURL,
        string memory _renderImageURL
    ) initializer public
    {
        __ERC721_init("LifeSpan", "LIFESPAN");
        __ERC721Enumerable_init();
        __Pausable_init();
        __AccessControl_init();
        __ERC721Burnable_init();
        __UUPSUpgradeable_init();

        externalURL = _externalURL;
        renderImageURL = _renderImageURL;

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
        _grantRole(OPERATOR_ROLE, msg.sender);
    }

    /// @notice Pause contract
    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /// @notice Unpause contract
    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    /**
     * @notice Safe mint LifeSpan token
     * @param to wallet address to which the token is mint
     * @param name of LifeSpan token
     * @param gender id of LifeSpan token
     * @param birthdayDate time in sec when the token(user) was born
     */
    function safeMint(address to, string memory name, uint256 gender, uint256 birthdayDate) public onlyRole(MINTER_ROLE) {
        require(bytes(genders[gender].name).length != 0, "ERC721Metadata: Gender not exists");
        require(genders[gender].isActive, "ERC721Metadata: Gender not active");
        require(birthdayDate < block.timestamp, "ERC721Metadata: Invalid date");

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        tokenData[tokenId] = TokenData(name, gender, birthdayDate, block.timestamp);
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

        bytes memory dataURI = abi.encodePacked(baseSection(tokenId), attributesSection(tokenId));

        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(dataURI)));
    }


    /**
     * @notice Change name of LifeSpan token
     * @param tokenId id LifeSpan token
     * @param newName new name of LifeSpan token
     */
    function updateName(uint256 tokenId, string memory newName) public {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        require(ownerOf(tokenId) == msg.sender, "ERC721: you are not the owner of the token");

        tokenData[tokenId].name = newName;
    }

    /**
     * @notice Change gender of LifeSpan token
     * @param tokenId id LifeSpan token
     * @param newGender id new gender of LifeSpan token
     */
    function updateGender(uint256 tokenId, uint256 newGender) public {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        require(ownerOf(tokenId) == msg.sender, "ERC721: you are not the owner of the token");
        require(bytes(genders[newGender].name).length != 0, "ERC721Metadata: Gender not exists");
        require(genders[newGender].isActive, "ERC721Metadata: Gender not active");

        tokenData[tokenId].gender = newGender;
    }

    /**
     * @notice Add new gender
     * @param id of new gender
     * @param newGender name of new gender
     */
    function addGender(uint256 id, string memory newGender) public onlyRole(OPERATOR_ROLE) {
        require(bytes(genders[id].name).length == 0, "ERC721Metadata: Gender already exists");

        genders[id].name = newGender;
        genders[id].isActive = true;
    }

    /**
     * @notice Enable or disable gender
     * @param id of gender
     * @param isActive true or false
     */
    function setIsActiveGender(uint256 id, bool isActive) public onlyRole(OPERATOR_ROLE) {
        require(bytes(genders[id].name).length != 0, "ERC721Metadata: Gender not exists");

        genders[id].isActive = isActive;
    }

    /**
     * @notice Update external url LifeSpan
     * @param newExternalURL sting of new link
     */
    function updateExternalURL(string memory newExternalURL) public onlyRole(OPERATOR_ROLE) {
        externalURL = newExternalURL;
    }

    /**
     * @notice Update generator images LifeSpan
     * @param newRenderImageURL sting of new link
     */
    function updateRenderImageURL(string memory newRenderImageURL) public onlyRole(OPERATOR_ROLE) {
        renderImageURL = newRenderImageURL;
    }

    /**
     * @notice Get base section of LifeSpan token in json
     * @param tokenId id LifeSpan token
     * @return bytes(json) of base section
     */
    function baseSection(uint256 tokenId)
    private
    view
    returns (bytes memory)
    {
        return abi.encodePacked(
            '{',
            '"description":"Plush ecosystem avatar",',
            '"external_url": "', externalURL, tokenId.toString(), '",',
            '"name": "', tokenData[tokenId].name, "'s Plush Token", '",',
            '"image":"', renderImageURL,
            '?birthdayDate=', tokenData[tokenId].birthdayDate.toString(),
            '&name=', tokenData[tokenId].name,
            '&gender=', tokenData[tokenId].gender.toString(), '",'
        );
    }

    /**
     * @notice Get attributes of LifeSpan token in json
     * @param tokenId id LifeSpan token
     * @return bytes(json) of attributes
     */
    function attributesSection(uint256 tokenId)
    private
    view
    returns (bytes memory)
    {
        return abi.encodePacked(
            '"attributes":',
            '[{',
            '"display_type":"date","trait_type":"Birthday","value":"', tokenData[tokenId].birthdayDate.toString(), '"',
            '},{',
            '"display_type":"date","trait_type":"Date of Mint","value":"', tokenData[tokenId].dateOfMint.toString(), '"',
            '},{',
            '"trait_type":"Gender","value":"', genders[tokenData[tokenId].gender].name, '"',
            '}]',
            '}'
        );
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
