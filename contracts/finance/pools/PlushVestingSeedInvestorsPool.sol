// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../../interfaces/IPlushVestingSeedInvestorsPool.sol";

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

import "../../token/ERC721/PlushSeed.sol";

contract PlushVestingSeedInvestorsPool is
    IPlushVestingSeedInvestorsPool,
    Initializable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    IERC20Upgradeable public plush;
    PlushSeed public plushSeed;

    uint256 public idPlushSeed; // PlushSeed (NFT) token ID

    uint256 private mainPercent; //Percent release at IDO
    uint256 private daysUnlock; //How many days will it be unlocked
    uint256 private amountDaily; //Number of tokens broken into pieces
    uint256 private unlockBalance; //Number of tokens available for withdrawal (release at IDO)
    uint256 private timeStart; //Start counter start after (release at IDO)

    bool private isIDO;

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
        IERC20Upgradeable _plush,
        PlushSeed _plushSeed,
        uint256 _idPlushSeed,
        uint256 _mainPercent,
        uint256 _daysUnlock
    ) public initializer {
        plush = _plush;
        plushSeed = _plushSeed;
        idPlushSeed = _idPlushSeed;
        mainPercent = _mainPercent;
        daysUnlock = _daysUnlock;

        isIDO = false;

        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(OPERATOR_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
    }

    /**
     * @notice Returns how many tokens are locked
     * @return Number of tokens in wei
     */
    function getLockBalance() public view returns (uint256) {
        if (isIDO) {
            uint256 amountUnlockRemuneration = 0;

            for (
                uint256 i = 0;
                i < (block.timestamp - timeStart) / 1 days;
                i++
            ) {
                amountUnlockRemuneration += amountDaily;
            }

            if (
                (unlockBalance + amountUnlockRemuneration) >
                plush.balanceOf(address(this))
            ) {
                return 0;
            } else {
                return
                    plush.balanceOf(address(this)) -
                    (unlockBalance + amountUnlockRemuneration);
            }
        } else {
            return plush.balanceOf(address(this));
        }
    }

    /**
     * @notice Returns how many tokens are unlock
     * @return Number of tokens in wei
     */
    function getUnLockBalance() public view returns (uint256) {
        if (isIDO) {
            uint256 amountUnlockRemuneration = 0;

            for (
                uint256 i = 0;
                i < (block.timestamp - timeStart) / 1 days;
                i++
            ) {
                amountUnlockRemuneration += amountDaily;
            }

            if (
                (unlockBalance + amountUnlockRemuneration) >
                plush.balanceOf(address(this))
            ) {
                return plush.balanceOf(address(this));
            } else {
                return unlockBalance + amountUnlockRemuneration;
            }
        } else {
            return 0;
        }
    }

    /**
     * @notice Withdrawal of unlocked tokens
     */
    function withdraw() external {
        require(getUnLockBalance() > 0, "Insufficient funds.");
        require(
            plushSeed.ownerOf(idPlushSeed) == msg.sender,
            "You are not the owner of the lot."
        );

        uint256 unlockBalanceTemp = getUnLockBalance();
        uint256 timePast = block.timestamp - timeStart;

        unlockBalance = 0;

        while (timePast > 1 days) {
            timePast -= 1 days;
        }

        timeStart = block.timestamp - timePast;
        plush.safeTransfer(msg.sender, unlockBalanceTemp);

        emit WithdrawalTokens(msg.sender, unlockBalanceTemp);
    }

    /**
     * @notice Start release at IDO (unlocking the first part of the tokens and starting the reward every day)
     */
    function releaseAtIDO() external onlyRole(OPERATOR_ROLE) {
        require(!isIDO, "Already complete.");

        unlockBalance = (plush.balanceOf(address(this)) * mainPercent) / 100000;
        amountDaily =
            (plush.balanceOf(address(this)) - unlockBalance) /
            daysUnlock;
        timeStart = block.timestamp;
        isIDO = true;

        emit ReleaseIDO(msg.sender, timeStart);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(UPGRADER_ROLE)
    {}
}
