// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "../../token/ERC20/Plush.sol";

contract PlushLifeSpanNFTCashbackPool is Initializable, PausableUpgradeable, AccessControlUpgradeable, UUPSUpgradeable {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant REMUNERATION_ROLE = keccak256("REMUNERATION_ROLE");

    uint256 private remuneration;
    uint256 private timeUnlock;
    bool private unlockAllTokens;
    uint256[] allIds;

    Plush public token;

    struct Balance
    {
        uint256 balance;
        uint256 timeIsActive;
    }

    mapping (address => uint256[]) private idsBalances;
    mapping (uint256 => Balance) private balanceInfo;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize(Plush _plushCoin, uint256 _remuneration, uint256 _timeUnlock) initializer public
    {
        token = _plushCoin;
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

    function pause() public onlyRole(PAUSER_ROLE)
    {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE)
    {
        _unpause();
    }

    function addRemunerationToAccountManually(address _wallet, uint256 _amount) public onlyRole(OPERATOR_ROLE)
    {
        require(getFreeTokensInContract() >= _amount, "Not enough funds");

        uint256 id = idsBalances[_wallet].length;

        allIds.push(id);
        idsBalances[_wallet].push(id);

        balanceInfo[id] = Balance(_amount, 0);
    }

    function addRemunerationToAccount(address _wallet) public onlyRole(REMUNERATION_ROLE)
    {
        if(getFreeTokensInContract() >= remuneration){
            uint256 id = idsBalances[_wallet].length;

            allIds.push(id);
            idsBalances[_wallet].push(id);

            if(unlockAllTokens){
                balanceInfo[id] = Balance(remuneration, block.timestamp + timeUnlock);
            }else{
                balanceInfo[id] = Balance(remuneration, 0);
            }
        }
    }

    function withdraw(uint256 _amount) external
    {
        require(token.balanceOf(address(this)) >= _amount, "Pool is empty.");
        require(getAvailableBalanceInAccount(msg.sender) >= _amount, "Not enough balance.");
        require(token.transfer(msg.sender, _amount), "Transaction error.");

        decreaseWalletAmount(msg.sender, _amount);
    }

    function setRemuneration(uint256 _amount) public onlyRole(OPERATOR_ROLE)
    {
        remuneration = _amount;
    }

    function setTimeUnlock(uint256 _amount) public onlyRole(OPERATOR_ROLE)
    {
        timeUnlock = _amount;
    }

    function unlockAllTokensSwitch(bool _switch) public onlyRole(OPERATOR_ROLE)
    {
        unlockAllTokens = _switch;
    }

    function getWalletAmount(address _wallet) external view returns(uint256[] memory, uint256[] memory, uint256[] memory, uint256[] memory)
    {
        uint256[] memory availableBalance = new uint256[](idsBalances[_wallet].length);
        uint256[] memory availableTimeIsActive = new uint256[](idsBalances[_wallet].length);
        uint256[] memory unavailableBalance = new uint256[](idsBalances[_wallet].length);
        uint256[] memory unavailableTimeIsActive = new uint256[](idsBalances[_wallet].length);

        for(uint256 i = 0; i < idsBalances[_wallet].length; i++){
            if(unlockAllTokens || balanceInfo[i].timeIsActive != 0){
                if(balanceInfo[i].timeIsActive < block.timestamp){
                    availableBalance[i] = balanceInfo[i].balance;
                    availableTimeIsActive[i] = balanceInfo[i].timeIsActive;
                }else{
                    unavailableBalance[i] = balanceInfo[i].balance;
                    unavailableTimeIsActive[i] = balanceInfo[i].timeIsActive;
                }
            }else{
                unavailableBalance[i] = balanceInfo[i].balance;
                unavailableTimeIsActive[i] = balanceInfo[i].timeIsActive;
            }
        }

        return (availableBalance, availableTimeIsActive, unavailableBalance, unavailableTimeIsActive);
    }

    function getRemuneration() external view returns(uint256)
    {
        return remuneration;
    }

    function getTimeUnlock() external view returns(uint256)
    {
        return timeUnlock;
    }

    function getFreeTokensInContract() private view returns(uint256)
    {
        uint256 unavailableTokens = 0;

        for(uint256 i = 0; i < allIds.length; i++){
            unavailableTokens += balanceInfo[allIds[i]].balance;
        }

        return token.balanceOf(address(this)) - unavailableTokens;
    }

    function getAvailableBalanceInAccount(address _wallet) private view returns(uint256)
    {
        uint256 availableBalance = 0;

        for(uint256 i = 0; i < idsBalances[_wallet].length; i++){
            if(unlockAllTokens || balanceInfo[i].timeIsActive != 0){
                if(balanceInfo[i].timeIsActive < block.timestamp){
                    availableBalance += balanceInfo[i].balance;
                }
            }
        }

        return availableBalance;
    }

    function decreaseWalletAmount(address _wallet, uint256 _amount) private
    {
        uint256 summary = _amount;

        for(uint256 i = 0; i < idsBalances[_wallet].length; i++){
            if(unlockAllTokens || balanceInfo[i].timeIsActive != 0){
                if(balanceInfo[i].timeIsActive < block.timestamp){
                    if(summary < balanceInfo[i].balance){
                        balanceInfo[i].balance -= summary;
                        break;
                    }else if(summary == balanceInfo[i].balance){
                        deleteIdAndInfo(_wallet, i);
                        break;
                    }else{
                        summary -= balanceInfo[i].balance;
                        deleteIdAndInfo(_wallet, i);
                    }
                }
            }
        }
    }

    function deleteIdAndInfo(address _wallet, uint256 _id) private
    {
        delete balanceInfo[_id];
        delete allIds[_id];

        for (uint256 j = 0; j < idsBalances[_wallet].length; j++){
            if(idsBalances[_wallet][j] == _id){
                delete idsBalances[_wallet][j];
            }
        }
    }

    function _authorizeUpgrade(address newImplementation)
    internal
    onlyRole(UPGRADER_ROLE)
    override
    {}
}