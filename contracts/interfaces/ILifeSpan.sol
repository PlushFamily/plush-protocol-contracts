// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ILifeSpan {
    struct MetaData {
        string name;
        uint256 gender;
        uint256 birthdayDate;
    }

    struct Gender {
        string name;
        bool isActive;
    }

    /// @notice Pause contract
    function pause() external;

    /// @notice Unpause contract
    function unpause() external;

    /**
     * @notice Safe mint LifeSpan token
     * @param to wallet address to which the token is mint
     * @param name of LifeSpan token
     * @param gender id of LifeSpan token
     * @param birthdayDate time in sec when the token(user) was born
     */
    function safeMint(address to, string memory name, uint256 gender, uint256 birthdayDate) external;

    /**
     * @notice Add new gender
     * @param id of new gender
     * @param newGender name of new gender
     */
    function addGender(uint256 id, string memory newGender) external;

    /**
    * @notice Enable or disable gender
     * @param id of gender
     * @param isActive true or false
     */
    function setIsActiveGender(uint256 id, bool isActive) external;

    /**
    * @notice Change name of LifeSpan token
     * @param tokenId id LifeSpan token
     * @param newName new name of LifeSpan token
     */
    function updateName(uint256 tokenId, string memory newName) external;

    /**
     * @notice Change gender of LifeSpan token
     * @param tokenId id LifeSpan token
     * @param newGender id new gender of LifeSpan token
     */
    function updateGender(uint256 tokenId, uint256 newGender) external;

    /**
    * @notice Update external url LifeSpan
     * @param newExternalUrl sting of new link
     */
    function updateExternalUrl(string memory newExternalUrl) external;

    /**
     * @notice Update generator images LifeSpan
     * @param newGeneratorIMGUrl sting of new link
     */
    function updateGeneratorIMGUrl(string memory newGeneratorIMGUrl) external;
}
