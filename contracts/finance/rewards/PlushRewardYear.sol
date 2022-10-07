// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "../../interfaces/IPlushRewardYear.sol";

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

import "../../library/Date.sol";
import "../../token/ERC721/LifeSpan.sol";
import "../PlushAccounts.sol";
import "../../governance/PlushBlacklist.sol";

/// @custom:security-contact security@plush.family
contract PlushRewardYear is
    IPlushRewardYear,
    Initializable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable,
    Date
{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    IERC20Upgradeable public plush;
    PlushAccounts public plushAccounts;
    LifeSpan public lifeSpan;
    PlushBlacklist public plushBlacklist;

    uint256 public rewardEveryDay;
    uint256 public rewardMaxYear;

    mapping(uint256 => Account) public lifeSpanAccounts;

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
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        IERC20Upgradeable _plush,
        LifeSpan _lifeSpan,
        PlushBlacklist _plushBlacklist,
        PlushAccounts _plushAccounts,
        uint256 _rewardEveryMonth,
        uint256 _rewardMaxYear
    ) public initializer {
        plush = _plush;
        lifeSpan = _lifeSpan;
        plushAccounts = _plushAccounts;
        plushBlacklist = _plushBlacklist;
        rewardEveryDay = _rewardEveryMonth / 30;
        rewardMaxYear = _rewardMaxYear;

        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
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
     * @notice Check account balance
     * @param lifeSpanId requesting account
     * @return uint256 unlock balance in wei
     */
    function getBalance(uint256 lifeSpanId)
    public
    view
    returns (uint256)
    {
        require(
            lifeSpan.ownerOf(lifeSpanId) == msg.sender,
            "Token does not exist or you are not the owner"
        );
        require(
            lifeSpan.getBirthdayDate(lifeSpanId) > 0,
            "Birthday date empty"
        );
        require(
            lifeSpan.getDateOfMint(lifeSpanId) > 0,
            "Mint date empty"
        );

        DateT memory nowDay = DateT(getYear(block.timestamp), getMonth(block.timestamp), getDay(block.timestamp));
        uint256 dateNowTimestamp = toTimestamp(nowDay.year, nowDay.month, nowDay.day, 0, 0, 0);

        uint256 periodInDays = 0;

        if(lifeSpanAccounts[lifeSpanId].lastDateWithdraw == 0){
            DateT memory mint = DateT(getYear(lifeSpan.getDateOfMint(lifeSpanId)), getMonth(lifeSpan.getDateOfMint(lifeSpanId)), getDay(lifeSpan.getDateOfMint(lifeSpanId)));
            periodInDays = (dateNowTimestamp - toTimestamp(mint.year, mint.month, mint.day, 0, 0, 0)) / 1 days;
        }else{
            periodInDays = (dateNowTimestamp - lifeSpanAccounts[lifeSpanId].lastDateWithdraw) / 1 days;
        }

        if((periodInDays * rewardEveryDay) > rewardMaxYear){
            return rewardMaxYear;
        }

        return periodInDays * rewardEveryDay;
    }

    /**
     * @notice Withdraw reward tokens
     * @param lifeSpanId requesting account
     */
    function withdraw(uint256 lifeSpanId)
    external
    whenNotPaused
    notBlacklisted(msg.sender)
    {
        require(
            plush.balanceOf(address(this)) >= getBalance(lifeSpanId),
            "The reward system is empty"
        );
        require(
            isCanWithdraw(lifeSpanId) == true,
            "Your birthday hasn't arrived yet"
        );

        plush.safeApprove(address(plushAccounts), getBalance(lifeSpanId));
        plushAccounts.deposit(lifeSpan.ownerOf(lifeSpanId), getBalance(lifeSpanId));

        emit Withdraw(lifeSpan.ownerOf(lifeSpanId), getBalance(lifeSpanId));

        lifeSpanAccounts[lifeSpanId].lastDateWithdraw = block.timestamp;
    }

    function isCanWithdraw(uint256 lifeSpanId)
    public
    view
    returns (bool)
    {
        require(
            lifeSpan.ownerOf(lifeSpanId) == msg.sender,
            "Token does not exist or you are not the owner"
        );
        require(
            lifeSpan.getBirthdayDate(lifeSpanId) > 0,
            "Birthday date empty"
        );
        require(
            lifeSpan.getDateOfMint(lifeSpanId) > 0,
            "Mint date empty"
        );

        DateT memory nowDay = DateT(getYear(block.timestamp), getMonth(block.timestamp), getDay(block.timestamp));
        DateT memory birthday = DateT(getYear(lifeSpan.getBirthdayDate(lifeSpanId)), getMonth(lifeSpan.getBirthdayDate(lifeSpanId)), getDay(lifeSpan.getBirthdayDate(lifeSpanId)));
        DateT memory nextBirthdayMint = DateT(0, birthday.month, birthday.day);
        DateT memory mint = DateT(getYear(lifeSpan.getDateOfMint(lifeSpanId)), getMonth(lifeSpan.getDateOfMint(lifeSpanId)), getDay(lifeSpan.getDateOfMint(lifeSpanId)));
        DateT memory lastDateWithdrawDate = DateT(getYear(lifeSpanAccounts[lifeSpanId].lastDateWithdraw), getMonth(lifeSpanAccounts[lifeSpanId].lastDateWithdraw), getDay(lifeSpanAccounts[lifeSpanId].lastDateWithdraw));

        if(lifeSpanAccounts[lifeSpanId].lastDateWithdraw == 0){
            nextBirthdayMint.year = mint.year;

            if(toTimestamp(mint.year, mint.month, mint.day, 0, 0, 0) > toTimestamp(mint.year, birthday.month, birthday.day, 0, 0, 0)){
                nextBirthdayMint.year += 1;
            }
        }else{
            nextBirthdayMint.year = lastDateWithdrawDate.year;

            if(toTimestamp(lastDateWithdrawDate.year, lastDateWithdrawDate.month, lastDateWithdrawDate.day, 0, 0, 0) > toTimestamp(lastDateWithdrawDate.year, birthday.month, birthday.day, 0, 0, 0)){
                nextBirthdayMint.year += 1;
            }
        }

        if(toTimestamp(nowDay.year, nowDay.month, nowDay.day, 0, 0, 0) > toTimestamp(nextBirthdayMint.year, nextBirthdayMint.month, nextBirthdayMint.day, 0, 0, 0)){
            return true;
        }

        return false;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(UPGRADER_ROLE)
    {}
}
