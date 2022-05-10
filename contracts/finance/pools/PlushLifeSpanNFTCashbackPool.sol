// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

import "../../interfaces/IPlushLifeSpanNFTCashbackPool.sol";

contract PlushLifeSpanNFTCashbackPool is Initializable, PausableUpgradeable, AccessControlUpgradeable, UUPSUpgradeable, IPlushLifeSpanNFTCashbackPool {
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

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function addRemunerationToAccountManually(address account, uint256 amount) public onlyRole(OPERATOR_ROLE) {
        require(getFreeTokensInContract() >= amount, "Not enough funds");

        uint256 id = idsBalances[account].length;

        allIds.push(id);
        idsBalances[account].push(id);

        balanceInfo[id] = Balance(amount, 0);
    }

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

    function withdraw(uint256 amount) external {
        require(plush.balanceOf(address(this)) >= amount, "Pool is empty.");
        require(getAvailableBalanceInAccount(msg.sender) >= amount, "Not enough balance.");
        require(plush.transfer(msg.sender, amount), "Transaction error.");

        decreaseWalletAmount(msg.sender, amount);
    }

    function setRemuneration(uint256 amount) public onlyRole(OPERATOR_ROLE) {
        remuneration = amount;
    }

    function setTimeUnlock(uint256 amount) public onlyRole(OPERATOR_ROLE) {
        timeUnlock = amount;
    }

    function unlockAllTokensSwitch() public onlyRole(OPERATOR_ROLE) {
        unlockAllTokens = !unlockAllTokens;
    }

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

    function getRemuneration() external view returns (uint256) {
        return remuneration;
    }

    function getTimeUnlock() external view returns (uint256) {
        return timeUnlock;
    }

    function getFreeTokensInContract() private view returns (uint256) {
        uint256 unavailableTokens = 0;

        for (uint256 i = 0; i < allIds.length; i++) {
            unavailableTokens += balanceInfo[allIds[i]].balance;
        }

        return plush.balanceOf(address(this)) - unavailableTokens;
    }

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