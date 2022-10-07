// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ILifeSpan {
    struct TokenData {
        string name;
        uint256 gender;
        uint256 birthdayDate;
        uint256 deathDate;
        uint256 dateOfMint;
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
    function safeMint(
        address to,
        string memory name,
        uint256 gender,
        uint256 birthdayDate
    ) external;

    /**
     * @notice Add new gender
     * @param id of new gender
     * @param newGender name of new gender
     */
    function addGender(uint256 id, string memory newGender) external;

    /**
     * @notice Enable or disable gender
     * @param id of gender
     * @param status true or false
     */
    function setIsActiveGender(uint256 id, bool status) external;

    /**
     * @notice Change name of LifeSpan token
     * @param tokenId id LifeSpan token
     * @param newName new name of LifeSpan token
     */
    function updateTokenName(uint256 tokenId, string memory newName) external;

    /**
     * @notice Change gender of LifeSpan token
     * @param tokenId id LifeSpan token
     * @param newGender id new gender of LifeSpan token
     */
    function updateTokenGender(uint256 tokenId, uint256 newGender) external;

    /**
     * @notice Update external url LifeSpan
     * @param newExternalURL sting of new link
     */
    function updateExternalURL(string memory newExternalURL) external;

    /**
     * @notice Update generator images LifeSpan
     * @param newRenderImageURL sting of new link
     */
    function updateRenderImageURL(string memory newRenderImageURL) external;

    /**
     * @notice Get information about birthday date user token
     * @param _tokenId id LifeSpan token
     * @return uint256 birthday date
     */
    function getBirthdayDate(uint256 _tokenId) external view returns (uint256);

    /**
     * @notice Get information about date of mint token
     * @param _tokenId id LifeSpan token
     * @return uint256 date of mint
     */
    function getDateOfMint(uint256 _tokenId) external view returns (uint256);

    /**
     * @notice Get information about death date user token
     * @param _tokenId id LifeSpan token
     * @return uint256 death date
     */
    function getDeathDate(uint256 _tokenId) external view returns (uint256);
}
