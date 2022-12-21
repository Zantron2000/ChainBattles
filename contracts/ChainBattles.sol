// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

/**
    @title ChainBattles
    @author Xander Palmer
    @notice NFT Contract to mint and interact with ChainBattle NFTs
    @dev Details converted into Base64
*/
contract ChainBattles is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;

    struct Warrior {
        uint256 level;
        uint256 strength;
        uint256 speed;
        uint256 health;
    }
    
    Counters.Counter private _tokenIds;
    mapping(uint256 => Warrior) public tokenIdToCharacter;

    constructor() ERC721 ("Chain Battles", "CBTLS") {

    }

    /**
        @notice Generates and encodes the svg image of the token
        @dev Encodes image as xml into Base64
        @param tokenId The id of the token to obtain the image of
        @return The encoded image to display for the token
    */
    function generateCharacter(uint256 tokenId) public view returns(string memory){

        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            '<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>',
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',"Warrior",'</text>',
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">', "Levels: ",getLevels(tokenId),'</text>',
            '</svg>'
        );
        return string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(svg)
            )    
        );
    }

    /**
        @notice Gets the level of a given tokenId
        @param tokenId The id of the token to obtain the level of
        @return The level of the token
    */
    function getLevels(uint256 tokenId) public view returns (string memory) {
        uint256 levels = tokenIdToCharacter[tokenId].level;

        return levels.toString();
    }

    /**
        @notice Gets the health of a given tokenId
        @param tokenId The id of the token to obtain the health of
        @return The health of the token
    */
    function getHealth(uint256 tokenId) public view returns(string memory) {
        uint256 health = tokenIdToCharacter[tokenId].health;

        return health.toString();
    }

    /**
        @notice Gets the strength of a given tokenId
        @param tokenId The id of the token to obtain the strength of
        @return The strength of the token
    */
    function getStrength(uint256 tokenId) public view returns(string memory) {
        uint256 strength = tokenIdToCharacter[tokenId].strength;

        return strength.toString();
    }

    /**
        @notice Gets the speed of a given tokenId
        @param tokenId The id of the token to obtain the speed of
        @return The speed of the token
    */
    function getSpeed(uint256 tokenId) public view returns(string memory) {
        uint256 speed = tokenIdToCharacter[tokenId].speed;

        return speed.toString();
    }

    /**
        @notice Gets the information of the given token
        @dev Gets the json of the token with its information
        @param tokenId The id of the token to obtain the data of
        @return The information of the token in json
    */
    function getTokenURI(uint256 tokenId) public view returns (string memory){
        bytes memory dataURI = abi.encodePacked(

            '{',
                '"name": "Chain Battles #', tokenId.toString(), '",',
                '"description": "Battles on chain",',
                '"image": "', generateCharacter(tokenId), '",',
                '"attributes": [',
                    '{',
                        '"trait_type": "health",',
                        '"value": "', getHealth(tokenId), '"',
                    '},',
                    '{',
                        '"trait_type": "strength",',
                        '"value": "', getStrength(tokenId), '"',
                    '},',
                    '{',
                        '"trait_type": "speed",',
                        '"value": "', getSpeed(tokenId), '"',
                    '}',
                ']',
            '}'
        );
        
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }

    /**
        @notice Mints a NFT and sends it to the user
        @dev Calls ERC721's _safeMint and updates URI with SVG
    */
    function mint() public {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        
        tokenIdToCharacter[newItemId].level = 0;
        tokenIdToCharacter[newItemId].health = 10;
        tokenIdToCharacter[newItemId].strength = 6;
        tokenIdToCharacter[newItemId].speed = 3;

        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    /**
        @notice Levels up a token given the sender owners it
        @param tokenId The id of the token to train
    */
    function train(uint256 tokenId) public {
        require(_exists(tokenId), "Please use an existing token");
        require(ownerOf(tokenId) == msg.sender, "You must own this token to train it");
        uint256 currentLevel = tokenIdToCharacter[tokenId].level;
        tokenIdToCharacter[tokenId].level = currentLevel + 1;

        tokenIdToCharacter[tokenId].health += uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, tokenId.toString()))) % 10;
        tokenIdToCharacter[tokenId].strength += uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, tokenId.toString()))) % 6;
        tokenIdToCharacter[tokenId].speed += uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, tokenId.toString()))) % 3;

        _setTokenURI(tokenId, getTokenURI(tokenId));
    }
}