// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../interfaces/IPlushGetLifeSpan.sol";

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "../token/ERC721/LifeSpan.sol";
import "../governance/PlushBlacklist.sol";

/// @custom:security-contact security@plush.family
contract PlushGetLifeSpan is
    IPlushGetLifeSpan,
    Initializable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    LifeSpan public lifeSpan;
    PlushBlacklist public plushBlacklist;

    address public feeAddress; // Plush Fee collector address
    uint256 public mintPrice;

    modifier notBlacklisted(address _account) {
        require(
            !plushBlacklist.isBlacklisted(_account),
            "Blacklist: account is blacklisted"
        );
        _;
    }

    /**
     * @dev Roles definitions
     */
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant BANKER_ROLE = keccak256("BANKER_ROLE");
    bytes32 public constant STAFF_ROLE = keccak256("STAFF_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        LifeSpan _lifeSpan,
        PlushBlacklist _plushBlacklist,
        address payable _feeAddress,
        uint256 _mintPrice
    ) public initializer {
        lifeSpan = _lifeSpan;
        plushBlacklist = _plushBlacklist;
        feeAddress = _feeAddress;

        mintPrice = _mintPrice;

        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(BANKER_ROLE, msg.sender);
        _grantRole(STAFF_ROLE, msg.sender);
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
     * @notice Change mint price
     * @param _newPrice new LifeSpan token mint price
     */
    function changeMintPrice(uint256 _newPrice)
        external
        onlyRole(BANKER_ROLE)
        whenNotPaused
    {
        mintPrice = _newPrice;

        emit MintPriceChanged(_newPrice);
    }

    /**
     * @notice Set new fee address
     * @param _address new fee address
     */
    function setFeeAddress(address _address)
        external
        onlyRole(BANKER_ROLE)
        whenNotPaused
    {
        feeAddress = _address;

        emit FeeAddressChanged(_address);
    }

    /**
     * @notice Set new LifeSpan contract address
     * @param _address new LifeSpan contract address
     */
    function setLifeSpanAddress(address _address)
        external
        onlyRole(OPERATOR_ROLE)
        whenNotPaused
    {
        lifeSpan = LifeSpan(_address);

        emit LifeSpanAddressChanged(_address);
    }

    /**
     * @notice Mint LifeSpan token
     * @param _mintAddress where to enroll the LifeSpan token after minting
     * @param _name of token User (metadata)
     * @param _gender of token User (metadata)
     * @param _birthdayDate in sec of token User (metadata)
     */
    function mint(
        address _mintAddress,
        string memory _name,
        uint256 _gender,
        uint256 _birthdayDate
    )
        public
        payable
        whenNotPaused
        notBlacklisted(msg.sender)
        notBlacklisted(_mintAddress)
    {
        require(msg.value == mintPrice, "Incorrect amount");

        lifeSpan.safeMint(_mintAddress, _name, _gender, _birthdayDate);

        emit TokenMinted(msg.sender, _mintAddress, msg.value);
    }

    /**
     * @notice Free mint LifeSpan token for staffers
     * @param _mintAddress where to enroll the LifeSpan token after minting
     * @param _name of token User (metadata)
     * @param _gender of token User (metadata)
     * @param _birthdayDate in sec of token User (metadata)
     */
    function freeMint(
        address _mintAddress,
        string memory _name,
        uint256 _gender,
        uint256 _birthdayDate
    ) public onlyRole(STAFF_ROLE) whenNotPaused notBlacklisted(_mintAddress) {
        lifeSpan.safeMint(_mintAddress, _name, _gender, _birthdayDate);

        emit TokenFreeMinted(msg.sender, _mintAddress);
    }

    /**
     * @notice Withdraw mint fee on Plush Fee collector address
     * @param _amount withdraw amount
     */
    function withdraw(uint256 _amount)
        external
        onlyRole(BANKER_ROLE)
        whenNotPaused
    {
        require(
            _amount <= address(this).balance,
            "The withdrawal amount exceeds the contract balance"
        );

        payable(feeAddress).transfer(_amount);

        emit FeeWithdrawn(_amount, feeAddress);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(UPGRADER_ROLE)
    {}
}
