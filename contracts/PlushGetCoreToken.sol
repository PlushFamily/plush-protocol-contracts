// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./protocol/PlushCoreToken.sol";

/// @custom:security-contact security@plush.family
contract PlushGetCoreToken is Ownable {

    event coreTokenChecked
    (
        address _holder,
        uint _bal,
        bool _result
    );

    PlushCoreToken plushCoreToken;
    address  payable private safeAddress;
    uint256 public mintPrice;
    bool public tokenNFTCheck;
    bool public isActive;

    event TokenMinted(address indexed purchaser, address indexed beneficiary, uint256 amount);

    constructor(address _plushCoreAddress, address payable _safeAddress)
    {
        plushCoreToken = PlushCoreToken(_plushCoreAddress);
        safeAddress = _safeAddress;
        mintPrice = 0.001 ether;
        tokenNFTCheck = true;
        isActive = true;
    }

    function checkUserCoreToken(address _address) private returns (bool)
    {
        bool result = false;

        if (plushCoreToken.balanceOf(_address) > 0) {
            result = true;
        }

        emit coreTokenChecked(_address, plushCoreToken.balanceOf(_address), result);

        return result;
    }

    function pause() public onlyOwner
    {
        isActive = !isActive;
    }

    function changeTokenCheckStatus() public onlyOwner
    {
        require(isActive, "Contract is not active");

        tokenNFTCheck = !tokenNFTCheck;
    }

    function changeMintPrice(uint256 _price) public onlyOwner
    {
        require(isActive, "Contract is not active");

        mintPrice = _price;
    }

    function getMintPrice() external view returns (uint256)
    {
        return mintPrice;
    }

    function setSafeAddress(address _address) external onlyOwner
    {
        safeAddress = payable(_address);
    }

    function setCoreTokenAddress(address _address) external onlyOwner
    {
        plushCoreToken = PlushCoreToken(_address);
    }

    function getSafeAddress() public view returns (address payable)
    {
        return safeAddress;
    }

    function getCoreTokenAddress() external view onlyOwner returns (address)
    {
        return address(plushCoreToken);
    }

    function mint(address _mintAddress) payable public
    {
        require(isActive, "Contract is not active");
        require(msg.value == mintPrice, "Incorrect amount");

        if (tokenNFTCheck) {
            require(checkUserCoreToken(_mintAddress) == false, "You already have a Core token");
        }

        plushCoreToken.safeMint(_mintAddress);

        emit TokenMinted(_msgSender(), _mintAddress, msg.value);

        _forwardFunds();
    }

    function _forwardFunds() internal {
        (bool success, ) = safeAddress.call{value: msg.value}("");
        require(success, "Transfer failed.");
    }

}