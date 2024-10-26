// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CSIT6000 is ERC721URIStorage{

    address public owner;

    // Modifier to check that the caller is the owner of
    // the contract.
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        // Underscore is a special character only used inside
        // a function modifier and it tells Solidity to
        // execute the rest of the code.
        _;
    }


    constructor()
        ERC721("CSIT6000", "PRTK"){
            owner = msg.sender;
        }

    function safeMint(address to, uint256 tokenId, string memory uri)
        public onlyOwner
        
    {
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }




}