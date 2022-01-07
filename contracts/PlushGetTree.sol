// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./PlushForest.sol";
import "./Plush.sol";

/// @custom:security-contact security@plush.family
contract PlushGetTree is Ownable {

    PlushForest plushForest;
    Plush plush;
    bool public isActive;
    address safeAddress;

    mapping(string => Tree) treeMap;

    struct Tree {
        bool isValid;
        string name;
        uint256 price;
        uint256 count;
    }

    constructor(address _plushForestAddress, address _plushAddress, address _safeAddress)
    {
        isActive = true;
        plushForest = PlushForest(_plushForestAddress);
        plush = Plush(_plushAddress);
        safeAddress = _safeAddress;
    }

    function addTreeType(string memory _type, uint256 _price, uint256 _count) external onlyOwner {
        require(!treeMap[_type].isValid, 'This type of tree already exists');

        treeMap[_type] = Tree(true, _type, _price, _count);
    }

    function removeTreeType(string memory _type) external onlyOwner {
        require(treeMap[_type].isValid, 'Not a valid tree type.');
        delete treeMap[_type];
    }

    function getTreeTypeCount(string memory _type) external view returns(uint256) {
        require(treeMap[_type].isValid, 'Not a valid tree type.');
        return treeMap[_type].count;
    }

    function getTreeTypePrice(string memory _type) external view returns(uint256) {
        require(treeMap[_type].isValid, 'Not a valid tree type.');
        return treeMap[_type].price;
    }

    function setTreeTypePrice(string memory _type, uint256 _price) external onlyOwner {
        require(isActive);
        require(treeMap[_type].isValid, 'Not a valid tree type.');
        require(_price > 0);
        treeMap[_type].price = _price;
    }

    function setTreeTypeCount(string memory _type, uint256 _count) external onlyOwner {
        require(isActive);
        require(treeMap[_type].isValid, 'Not a valid tree type.');
        treeMap[_type].count = _count;
    }

    function setSafeAddress(address _address) external onlyOwner {
        safeAddress = _address;
    }

    function getSafeAddress() external view onlyOwner returns(address) {
        return safeAddress;
    }

    function mint(address _mintAddress, uint256 _amount, string memory _type) public {
        require(isActive);
        require(treeMap[_type].isValid, 'Not a valid tree type.');
        require(treeMap[_type].count > 0, 'The trees are over.');
        require(_amount == treeMap[_type].price, "Minting fee");
        require(plush.balanceOf(msg.sender) >= _amount, 'Not enough balance.');
        require(plush.allowance(msg.sender, address(this)) >= _amount, 'Not enough allowance.');

        plush.transferFrom(msg.sender, safeAddress, _amount);

        plushForest.safeMint(_mintAddress);
        treeMap[_type].count = treeMap[_type].count - 1;
    }

    function changeContractStatus() public onlyOwner {
        isActive = !isActive;
    }
}