// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../../interfaces/IPlushLifeSpanNFTCashbackPool.sol";

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

contract PlushLifeSpanNFTCashbackPool is IPlushLifeSpanNFTCashbackPool, Initializable, PausableUpgradeable, AccessControlUpgradeable, UUPSUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    IERC20Upgradeable public plush;

    uint256 private remuneration;
    uint256 private timeUnlock;
    bool private unlockAllTokens;
    uint256[] allIds;

    mapping(address => uint256[]) private idsBalances;
    mapping(uint256 => Balance) private balanceInfo;

    /**
     * @dev Roles definitions
     */
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant REMUNERATION_ROLE = keccak256("REMUNERATION_ROLE");

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize(IERC20Upgradeable _plush, uint256 _remuneration, uint256 _timeUnlock) initializer public {
        plush = _plush;
        remuneration = _remuneration;
        timeUnlock = _timeUnlock;
        unlockAllTokens = false;

        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(OPERATOR_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
        _grantRole(REMUNERATION_ROLE, msg.sender);
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
     * @notice Add remuneration to account manually
     * @param account address to add remuneration
     * @param amount of tokens in wei
     */
    function addRemunerationToAccountManually(address account, uint256 amount) public onlyRole(OPERATOR_ROLE) {
        require(getFreeTokensInContract() >= amount, "Not enough funds");

        uint256 id = idsBalances[account].length;

        allIds.push(id);
        idsBalances[account].push(id);

        balanceInfo[id] = Balance(amount, 0);

        emit RemunerationManually(msg.sender, account, amount);
    }

    /**
     * @notice Add remuneration to account
     * @param account address to add remuneration
     */
    function addRemunerationToAccount(address account) public onlyRole(REMUNERATION_ROLE) {
        if (getFreeTokensInContract() >= remuneration) {
            uint256 id = idsBalances[account].length;

            allIds.push(id);
            idsBalances[account].push(id);

            if (unlockAllTokens) {
                balanceInfo[id] = Balance(remuneration, block.timestamp + timeUnlock);
            } else {
                balanceInfo[id] = Balance(remuneration, 0);
            }
        }
    }

    /**
     * @notice Withdrawal tokens to address
     * @param amount of tokens in wei
     */
    function withdraw(uint256 amount) external {
        require(plush.balanceOf(address(this)) >= amount, "Pool is empty.");
        require(getAvailableBalanceInAccount(msg.sender) >= amount, "Not enough balance.");

        plush.safeTransfer(msg.sender, amount);

        decreaseWalletAmount(msg.sender, amount);

        emit WithdrawalTokens(msg.sender, amount);
    }

    /**
     * @notice Set remuneration
     * @param amount of tokens in wei
     */
    function setRemuneration(uint256 amount) public onlyRole(OPERATOR_ROLE) {
        remuneration = amount;
    }

    /**
     * @notice Set time lock
     * @param amount time in sec
     */
    function setTimeUnlock(uint256 amount) public onlyRole(OPERATOR_ROLE) {
        timeUnlock = amount;
    }

    /**
     * @notice Switch to unlock all tokens
     */
    function unlockAllTokensSwitch() public onlyRole(OPERATOR_ROLE) {
        unlockAllTokens = !unlockAllTokens;
    }

    /**
     * @notice Get wallet amount in wei
     * @param account address
     * @return array of lock and unlock tokens
     */
    function getWalletAmount(address account) external view returns (uint256[] memory, uint256[] memory, uint256[] memory, uint256[] memory) {
        uint256[] memory availableBalance = new uint256[](idsBalances[account].length);
        uint256[] memory availableTimeIsActive = new uint256[](idsBalances[account].length);
        uint256[] memory unavailableBalance = new uint256[](idsBalances[account].length);
        uint256[] memory unavailableTimeIsActive = new uint256[](idsBalances[account].length);

        for (uint256 i = 0; i < idsBalances[account].length; i++) {
            if (unlockAllTokens || balanceInfo[i].timeIsActive != 0) {
                if (balanceInfo[i].timeIsActive < block.timestamp) {
                    availableBalance[i] = balanceInfo[i].balance;
                    availableTimeIsActive[i] = balanceInfo[i].timeIsActive;
                } else {
                    unavailableBalance[i] = balanceInfo[i].balance;
                    unavailableTimeIsActive[i] = balanceInfo[i].timeIsActive;
                }
            } else {
                unavailableBalance[i] = balanceInfo[i].balance;
                unavailableTimeIsActive[i] = balanceInfo[i].timeIsActive;
            }
        }

        return (availableBalance, availableTimeIsActive, unavailableBalance, unavailableTimeIsActive);
    }

    /**
     * @notice Get remuneration
     * @return amount of tokens in wei
     */
    function getRemuneration() external view returns (uint256) {
        return remuneration;
    }

    /**
     * @notice Get time unlock
     * @return amount time in sec
     */
    function getTimeUnlock() external view returns (uint256) {
        return timeUnlock;
    }

    /**
     * @notice Get available tokens in the contract
     * @return amount of tokens in wei
     */
    function getFreeTokensInContract() private view returns (uint256) {
        uint256 unavailableTokens = 0;

        for (uint256 i = 0; i < allIds.length; i++) {
            unavailableTokens += balanceInfo[allIds[i]].balance;
        }

        return plush.balanceOf(address(this)) - unavailableTokens;
    }

    /**
     * @notice Get available tokens in the account
     * @return amount of tokens in wei
     */
    function getAvailableBalanceInAccount(address account) private view returns (uint256) {
        uint256 availableBalance = 0;

        for (uint256 i = 0; i < idsBalances[account].length; i++) {
            if (unlockAllTokens || balanceInfo[i].timeIsActive != 0) {
                if (balanceInfo[i].timeIsActive < block.timestamp) {
                    availableBalance += balanceInfo[i].balance;
                }
            }
        }

        return availableBalance;
    }

    /**
     * @notice Decrease in the user's balance when withdrawing funds
     * @param account address
     * @param amount tokens in wei
     */
    function decreaseWalletAmount(address account, uint256 amount) private {
        uint256 summary = amount;

        for (uint256 i = 0; i < idsBalances[account].length; i++) {
            if (unlockAllTokens || balanceInfo[i].timeIsActive != 0) {
                if (balanceInfo[i].timeIsActive < block.timestamp) {
                    if (summary < balanceInfo[i].balance) {
                        balanceInfo[i].balance -= summary;
                        break;
                    } else if (summary == balanceInfo[i].balance) {
                        deleteIdAndInfo(account, i);
                        break;
                    } else {
                        summary -= balanceInfo[i].balance;
                        deleteIdAndInfo(account, i);
                    }
                }
            }
        }
    }

    /**
     * @notice Deleting information about the reward when withdrawing
     * @param account address
     * @param id remuneration id
     */
    function deleteIdAndInfo(address account, uint256 id) private {
        delete balanceInfo[id];
        delete allIds[id];

        for (uint256 j = 0; j < idsBalances[account].length; j++) {
            if (idsBalances[account][j] == id) {
                delete idsBalances[account][j];
            }
        }
    }

    function _authorizeUpgrade(address newImplementation)
    internal
    onlyRole(UPGRADER_ROLE)
    override
    {}
}