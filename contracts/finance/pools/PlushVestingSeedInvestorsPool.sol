// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../../interfaces/IPlushVestingSeedInvestorsPool.sol";

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

contract PlushVestingSeedInvestorsPool is IPlushVestingSeedInvestorsPool, Initializable, PausableUpgradeable, AccessControlUpgradeable, UUPSUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    IERC20Upgradeable public plush;
    IERC20Upgradeable public usdt;
    IERC20Upgradeable public usdc;

    uint256 private mainPercent; //Percent release at IDO

    uint256 private daysUnlock; //How many days will it be unlocked
    uint256 private amountDaily; //Number of tokens broken into pieces

    uint256 private unlockBalance; //Number of tokens available for withdrawal (release at IDO)
    uint256 private timeStart; //Start counter start after (release at IDO)
    uint256 private timeRemuneration; //The time when the next part of the tokens will be unlocked

    address private walletDAO;

    bool private isIDO;
    bool private isSold;
    bool private isReserved;
    address public investor;

    uint256 public totalPrice;
    uint256 public reservePrice;
    uint256 private fullPrice;

    /**
     * @dev Roles definitions
     */
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant WITHDRAW_ROLE = keccak256("WITHDRAW_ROLE");

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize(IERC20Upgradeable _plush, IERC20Upgradeable _usdt, IERC20Upgradeable _usdc, address _walletDAO, uint256 _reservePrice, uint256 _fullPrice, uint256 _mainPercent, uint256 _daysUnlock) initializer public {
        plush = _plush;
        usdt = _usdt;
        usdc = _usdc;
        mainPercent = _mainPercent;
        daysUnlock = _daysUnlock;
        reservePrice = _reservePrice;
        fullPrice = _fullPrice;
        totalPrice = _fullPrice;
        walletDAO = _walletDAO;
        isIDO = false;
        isSold = false;
        isReserved = false;
        timeRemuneration = 50;

        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(OPERATOR_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
        _grantRole(WITHDRAW_ROLE, msg.sender);
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
     * @notice Reserve of a lot by USDT
     */
    function reserveByUSDT() external whenNotPaused() {
        require(!isReserved, "Slot reserved.");
        require(!isSold, "Slot sold.");
        require(usdt.balanceOf(msg.sender) >= reservePrice);

        usdt.safeTransferFrom(msg.sender, address(this), reservePrice);
        usdt.safeTransfer(walletDAO, reservePrice);
        isReserved = true;
        investor = msg.sender;
        totalPrice -= reservePrice;

        emit ReserveByUSDT(msg.sender, reservePrice);
    }

    /**
     * @notice Reserve of a lot by USDC
     */
    function reserveByUSDC() external whenNotPaused() {
        require(!isReserved, "Slot reserved.");
        require(!isSold, "Slot sold.");
        require(usdc.balanceOf(msg.sender) >= reservePrice);

        usdc.safeTransferFrom(msg.sender, address(this), reservePrice);
        usdc.safeTransfer(walletDAO, reservePrice);

        isReserved = true;
        investor = msg.sender;
        totalPrice -= reservePrice;

        emit ReserveByUSDC(msg.sender, reservePrice);
    }

    /**
     * @notice Complete purchase of a lot by USDT
     */
    function sellByUSDT() external whenNotPaused() {
        require(!isReserved || (isReserved && msg.sender == investor), "Slot reserved.");
        require(!isSold, "Slot sold.");
        require(usdt.balanceOf(msg.sender) >= totalPrice);

        usdt.safeTransferFrom(msg.sender, address(this), totalPrice);
        usdt.safeTransfer(walletDAO, totalPrice);

        isReserved = true;
        isSold = true;
        investor = msg.sender;

        emit SellByUSDT(msg.sender, totalPrice);

        totalPrice = 0;
    }

    /**
     * @notice Complete purchase of a lot by USDC
     */
    function sellByUSDC() external whenNotPaused() {
        require(!isReserved || (isReserved && msg.sender == investor), "Slot reserved.");
        require(!isSold, "Slot sold.");
        require(usdc.balanceOf(msg.sender) >= totalPrice);

        usdc.safeTransferFrom(msg.sender, address(this), totalPrice);
        usdc.safeTransfer(walletDAO, totalPrice);

        isReserved = true;
        isSold = true;
        investor = msg.sender;

        emit SellByUSDC(msg.sender, totalPrice);

        totalPrice = 0;
    }

    /**
     * @notice Cancel reserve lot manually
     */
    function cancelReserve() external whenNotPaused() onlyRole(OPERATOR_ROLE) {
        require(!isSold, "Slot sold.");
        require(isReserved, "Slot not reserved.");

        isReserved = false;
        totalPrice = fullPrice;

        delete(investor);
    }

    /**
     * @notice Sell lot manually
     * @param wallet address of the user to which we sell this lot
     */
    function sellManually(address wallet) external whenNotPaused() onlyRole(OPERATOR_ROLE) {
        require(!isReserved || (isReserved && wallet == investor), "The wrong investor. Slot was reserved.");
        require(!isSold, "Slot sold.");

        isReserved = true;
        isSold = true;
        investor = wallet;

        emit SellManually(wallet, totalPrice);

        totalPrice = 0;
    }

    /**
     * @notice Reserve lot manually
     * @param wallet address of the user to which we reserve this lot
     */
    function reserveManually(address wallet) external whenNotPaused() onlyRole(OPERATOR_ROLE) {
        require(!isSold, "Slot sold.");
        require(!isReserved, "Slot reserved.");

        isReserved = true;
        investor = wallet;
        totalPrice -= reservePrice;

        emit ReserveManually(wallet, reservePrice);
    }

    /**
     * @notice Returns whether the lot was sold
     * @return bool lot was sold
     */
    function getIsSold() public whenNotPaused() view returns(bool) {
        return isSold;
    }

    /**
     * @notice Returns whether the lot was reserved
     * @return bool lot was reserved
     */
    function getIsReserved() public whenNotPaused() view returns(bool){
        return isReserved;
    }

    /**
     * @notice Returns how many tokens are locked
     * @return Number of tokens in wei
     */
    function getLockBalance() public whenNotPaused() view returns(uint256) {
        if(isIDO && isSold){
            uint256 amountUnlockRemuneration = 0;

            for(uint256 i = 0; i < (block.timestamp - timeStart) / timeRemuneration; i++){
                amountUnlockRemuneration += amountDaily;
            }

            if(unlockBalance + amountUnlockRemuneration > plush.balanceOf(address(this))){
                return 0;
            }else{
                return plush.balanceOf(address(this)) - (unlockBalance + amountUnlockRemuneration);
            }
        }else{
            if(!isSold){
                return 0;
            }else{
                return plush.balanceOf(address(this));
            }
        }
    }

    /**
     * @notice Returns how many tokens are unlock
     * @return Number of tokens in wei
     */
    function getUnLockBalance() public whenNotPaused() view returns(uint256) {
        if(isIDO && isSold){
            uint256 amountUnlockRemuneration = 0;

            for(uint256 i = 0; i < (block.timestamp - timeStart) / timeRemuneration; i++){
                amountUnlockRemuneration += amountDaily;
            }

            if(unlockBalance + amountUnlockRemuneration > plush.balanceOf(address(this))){
                return plush.balanceOf(address(this));
            }else{
                return unlockBalance + amountUnlockRemuneration;
            }
        }else{
            return 0;
        }
    }

    /**
     * @notice Withdrawal of unlocked tokens
     */
    function withdraw() external whenNotPaused() {
        require(isSold, "Slot was not purchased.");
        require(msg.sender == investor, "You have no rights.");
        require(getUnLockBalance() > 0, "Insufficient funds.");

        uint256 unlockBalanceTemp = getUnLockBalance();
        uint256 timePast = block.timestamp - timeStart;

        unlockBalance = 0;

        while(timePast > timeRemuneration){
            timePast -= timeRemuneration;
        }

        timeStart = block.timestamp - timePast;
        plush.safeTransfer(msg.sender, unlockBalanceTemp);

        emit WithdrawalTokens(msg.sender, unlockBalanceTemp);
    }

    /**
     * @notice Start release at IDO (unlocking the first part of the tokens and starting the reward every day)
     */
    function releaseAtIDO() external whenNotPaused() onlyRole(OPERATOR_ROLE) {
        require(!isIDO, "Already complete.");
        require(isSold, "Slot was not purchased.");

        unlockBalance = plush.balanceOf(address(this)) * mainPercent / 100000;
        amountDaily = (plush.balanceOf(address(this)) - unlockBalance) / daysUnlock;
        timeStart = block.timestamp;
        isIDO = true;

        emit ReleaseIDO(msg.sender, timeStart);
    }

    function _authorizeUpgrade(address newImplementation)
    internal
    onlyRole(UPGRADER_ROLE)
    override
    {}
}