// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts@5.0.0/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@5.0.0/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@5.0.0/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts@5.0.0/access/Ownable.sol";
import "@openzeppelin/contracts@5.0.0/interfaces/IERC2981.sol";

contract NinjaNFT is ERC721, ERC721URIStorage, ERC721Burnable, Ownable {
    enum Rank {
        Apprentice,
        Novice,
        Warrior,
        Shadow,
        Assassin,
        Master,
        Grandmaster,
        Elite,
        Legend,
        Supreme
    }
    enum Faction {
        ShadowClan,
        DragonClan,
        TigerClan,
        PhoenixClan,
        SerpentClan,
        WolfClan,
        EagleClan,
        LionClan,
        BearClan,
        HawkClan
    }

    constructor(address initialOwner) ERC721("NinjaNFT", "NINFT") Ownable(initialOwner) {}

    function safeMint(address to, string memory uri, Faction factionId, Rank ninjaLevel) public onlyOwner {
        uint256 tokenId = generateTokenId(factionId, ninjaLevel);
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }



    /*
    * we use faction and rank as IDs of each Ninja token
    */
    function generateTokenId(Faction factionId, Rank ninjaLevel) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(factionId, ninjaLevel, msg.sig)));
    }
}
