// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./PlushForestToken.sol";
import "./Plai.sol";

/// @custom:security-contact hello@plush.family
contract PlushGetTree is Ownable {

    PlushForestToken plushForest;
    Plai plai;
    bool public isActive;
    address safeAddress;
    string[] trees;

    mapping(string => Tree) treeMap;

    struct Tree {
        bool isValid;
        string name;
        uint256 price;
        uint256 count;
    }

    constructor(address _plushForestAddress, address _plaiAddress, address _safeAddress)
    {
        isActive = true;
        plushForest = PlushForestToken(_plushForestAddress);
        plai = Plai(_plaiAddress);
        safeAddress = _safeAddress;
    }

    function addTreeType(string memory _type, uint256 _price, uint256 _count) external onlyOwner {
        require(!treeMap[_type].isValid, 'This type of tree already exists');

        trees.push(_type);
        treeMap[_type] = Tree(true, _type, _price, _count);
    }

    function removeTreeType(string memory _type) external onlyOwner {
        require(treeMap[_type].isValid, 'Not a valid tree type.');

        uint256 index;

        for (uint256 i = 0; i < trees.length; i++) {
            if (keccak256(abi.encodePacked(trees[i])) == keccak256(abi.encodePacked(_type))) {
                index = i;
            }
        }

        trees[index] = trees[trees.length - 1];

        trees.pop();
        delete treeMap[_type];
    }

    function getTreeTypes() external view returns(string[] memory) {
        return trees;
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

        plushForest.safeMint(_mintAddress);
        treeMap[_type].count = treeMap[_type].count - 1;
        plai.transferFrom(msg.sender, safeAddress, _amount);
    }

    function changeContractStatus() public onlyOwner {
        isActive = !isActive;
    }
}