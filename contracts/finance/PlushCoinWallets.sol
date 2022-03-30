// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "../PlushApps.sol";
import "../token/ERC20/Plush.sol";

contract PlushCoinWallets is Initializable, PausableUpgradeable, AccessControlUpgradeable, UUPSUpgradeable {

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    Plush plush;
    PlushApps plushApps;

    uint256 minimumBet;
    address plushFeeWallet;

    struct Wallet
    {
        uint256 balance;
    }

    mapping(address => Wallet) public walletInfo;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize(Plush _plush, PlushApps _plushApps, address _plushFeeAddress) initializer public {
        plushApps = _plushApps;
        plush = _plush;
        minimumBet = 1 * 10 ** plush.decimals();
        plushFeeWallet = _plushFeeAddress;

        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(OPERATOR_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function deposit(address _wallet, uint256 _amount) public
    {
        require(plush.balanceOf(msg.sender) >= _amount, "Not enough balance.");
        require(plush.allowance(msg.sender, address(this)) >= _amount, "Not enough allowance.");

        plush.transferFrom(msg.sender, address(this), _amount);
        increaseWalletAmount(_wallet, _amount);
    }

    function withdraw(uint256 _amount) external
    {
        require(walletInfo[msg.sender].balance >= _amount, "Not enough balance.");

        walletInfo[msg.sender].balance -= _amount;
        plush.transfer(msg.sender, _amount);
    }

    function withdrawByController(uint256 _amount, address _address) external
    {
        require(walletInfo[msg.sender].balance >= _amount, "Not enough balance.");

        walletInfo[msg.sender].balance -= _amount;
        plush.transfer(_address, _amount);
    }

    function increaseWalletAmount(address _wallet, uint256 _amount) private
    {
        require(_amount >= minimumBet, "Less than minimum deposit.");

        walletInfo[_wallet].balance += _amount;
    }

    function internalTransfer(address _wallet, uint256 _amount) public
    {
        require(walletInfo[msg.sender].balance >= _amount, "Not enough balance(Sender).");

        walletInfo[msg.sender].balance -= _amount;
        walletInfo[_wallet].balance += _amount;
    }

    function decreaseWalletAmount(address _wallet, uint256 _amount) public
    {
        require(walletInfo[_wallet].balance >= _amount, "Not enough balance.");
        require(plushApps.getIsAddressActive(msg.sender) == true, "You have no rights.");

        uint256 percent = _amount * plushApps.getFeeApp(msg.sender) / 100000;

        walletInfo[_wallet].balance -= _amount;
        walletInfo[msg.sender].balance += _amount - percent;
        walletInfo[plushFeeWallet].balance += percent;
    }

    function getPlushFeeWalletAmount() external onlyRole(OPERATOR_ROLE) view returns(uint256)
    {
        return walletInfo[plushFeeWallet].balance;
    }

    function getWalletAmount(address _wallet) external view returns(uint256)
    {
        return walletInfo[_wallet].balance;
    }

    function setMinimumAmount(uint256 _amount) external onlyRole(OPERATOR_ROLE)
    {
        minimumBet = _amount;
    }

    function getMinimumAmount() external view returns(uint256)
    {
        return minimumBet;
    }

    function setPlushFeeAddress(address _address) external onlyRole(OPERATOR_ROLE)
    {
        plushFeeWallet = _address;
    }

    function getPlushFeeAddress() external onlyRole(OPERATOR_ROLE) view returns(address)
    {
        return plushFeeWallet;
    }

    function _authorizeUpgrade(address newImplementation)
    internal
    onlyRole(UPGRADER_ROLE)
    override
    {}
}