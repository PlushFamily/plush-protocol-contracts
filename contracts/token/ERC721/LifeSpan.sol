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

import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/Base64Upgradeable.sol";

/// @custom:security-contact security@plush.family
contract LifeSpan is
    ILifeSpan,
    Initializable,
    ERC721Upgradeable,
    ERC721EnumerableUpgradeable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    ERC721BurnableUpgradeable,
    UUPSUpgradeable
{
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using StringsUpgradeable for uint256;

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
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        string memory _externalURL,
        string memory _renderImageURL
    ) public initializer {
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
        _grantRole(OPERATOR_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
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
     * @notice Safe mint of LifeSpan token
     * @param _to the address of the token recipient
     * @param _name of LifeSpan token
     * @param _gender id of LifeSpan token
     * @param _birthdayDate date of birth of the token owner in the timestamp
     */
    function safeMint(
        address _to,
        string memory _name,
        uint256 _gender,
        uint256 _birthdayDate
    ) public onlyRole(MINTER_ROLE) whenNotPaused {
        require(
            bytes(genders[_gender].name).length != 0,
            "ERC721Metadata: Gender doesn't exist"
        );
        require(
            genders[_gender].isActive,
            "ERC721Metadata: Gender isn't active"
        );
        require(
            _birthdayDate < block.timestamp,
            "ERC721Metadata: Invalid date"
        );

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(_to, tokenId);
        tokenData[tokenId] = TokenData(
            _name,
            _gender,
            _birthdayDate,
            0,
            block.timestamp
        );
    }

    /**
     * @notice Get information about the token in JSON
     * @param _tokenId id LifeSpan token
     * @return base64(JSON) data of LifeSpan
     */
    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(_exists(_tokenId), "ERC721Metadata: The token doesn't exist");

        bytes memory data = abi.encodePacked(
            baseSection(_tokenId),
            attributesSection(_tokenId)
        );
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64Upgradeable.encode(data)
                )
            );
    }

    /**
     * @notice Change the name in the token
     * @param _tokenId id LifeSpan token
     * @param _newName new name of the token owner
     */
    function updateTokenName(uint256 _tokenId, string memory _newName)
        external
        whenNotPaused
    {
        require(_exists(_tokenId), "ERC721Metadata: The token doesn't exist");
        require(
            ownerOf(_tokenId) == msg.sender,
            "ERC721: You aren't the token owner"
        );

        tokenData[_tokenId].name = _newName;
    }

    /**
     * @notice Change the gender in the token
     * @param _tokenId id LifeSpan token
     * @param _newGender id new gender of the token owner
     */
    function updateTokenGender(uint256 _tokenId, uint256 _newGender)
        external
        whenNotPaused
    {
        require(_exists(_tokenId), "ERC721Metadata: The token doesn't exist");
        require(
            ownerOf(_tokenId) == msg.sender,
            "ERC721: You aren't the token owner"
        );
        require(
            bytes(genders[_newGender].name).length != 0,
            "ERC721Metadata: Gender doesn't exist"
        );
        require(
            genders[_newGender].isActive,
            "ERC721Metadata: Gender isn't active"
        );

        tokenData[_tokenId].gender = _newGender;
    }

    /**
     * @notice Add a new gender to the list of available
     * @param _id of new gender
     * @param _newGender name of new gender
     */
    function addGender(uint256 _id, string memory _newGender)
        external
        onlyRole(OPERATOR_ROLE)
        whenNotPaused
    {
        require(
            bytes(genders[_id].name).length == 0,
            "ERC721Metadata: Gender already exists"
        );

        genders[_id].name = _newGender;
        genders[_id].isActive = true;
    }

    /**
     * @notice Enable or disable gender from the list of available to choose
     * @param _id of gender
     * @param _status true or false
     */
    function setIsActiveGender(uint256 _id, bool _status)
        external
        onlyRole(OPERATOR_ROLE)
        whenNotPaused
    {
        require(
            bytes(genders[_id].name).length != 0,
            "ERC721Metadata: Gender doesn't exist"
        );

        genders[_id].isActive = _status;
    }

    /**
     * @notice Update external URL of LifeSpan token's
     * @param _newExternalURL string of new URL
     */
    function updateExternalURL(string memory _newExternalURL)
        external
        onlyRole(OPERATOR_ROLE)
        whenNotPaused
    {
        externalURL = _newExternalURL;
    }

    /**
     * @notice Update the URL to the token renderer
     * @param _newRenderImageURL string of new URL
     */
    function updateRenderImageURL(string memory _newRenderImageURL)
        external
        onlyRole(OPERATOR_ROLE)
        whenNotPaused
    {
        renderImageURL = _newRenderImageURL;
    }

    /**
     * @notice Get base section of LifeSpan token in JSON
     * @param _tokenId id LifeSpan token
     * @return bytes(JSON) of base section
     */
    function baseSection(uint256 _tokenId) private view returns (bytes memory) {
        return
            abi.encodePacked(
                "{",
                '"description":"Plush ecosystem avatar",',
                '"external_url": "',
                externalURL,
                _tokenId.toString(),
                '",',
                '"name": "',
                tokenData[_tokenId].name,
                "'s Plush Token",
                '",',
                '"image":"',
                renderImageURL,
                "?birthdayDate=",
                tokenData[_tokenId].birthdayDate.toString(),
                "&name=",
                tokenData[_tokenId].name,
                "&gender=",
                tokenData[_tokenId].gender.toString(),
                '",'
            );
    }

    /**
     * @notice Get attributes of LifeSpan token in JSON
     * @param _tokenId id LifeSpan token
     * @return bytes(JSON) of attributes
     */
    function attributesSection(uint256 _tokenId)
        private
        view
        returns (bytes memory)
    {
        return
            abi.encodePacked(
                '"attributes":',
                "[{",
                '"display_type":"date","trait_type":"Birthday","value":',
                tokenData[_tokenId].birthdayDate.toString(),
                "",
                "},{",
                '"display_type":"date","trait_type":"Date of Mint","value":',
                tokenData[_tokenId].dateOfMint.toString(),
                "",
                "},{",
                '"trait_type":"Gender","value":"',
                genders[tokenData[_tokenId].gender].name,
                '"',
                "}]",
                "}"
            );
    }

    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _tokenId
    )
        internal
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
        whenNotPaused
    {
        super._beforeTokenTransfer(_from, _to, _tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(
            ERC721Upgradeable,
            ERC721EnumerableUpgradeable,
            AccessControlUpgradeable
        )
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(UPGRADER_ROLE)
    {}
}
