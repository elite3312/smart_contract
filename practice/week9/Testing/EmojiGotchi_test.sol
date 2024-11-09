// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "../EmojiGotchi.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract testSuite {

    EmojiGotchi emojiGotchi;


    function beforeAll() public {
        emojiGotchi = new EmojiGotchi();
    }

    function testInitialNameAndSymbol() public {
        string memory expectedName = "EmojiGotchi";
        string memory expectedSymbol = "emg";

        Assert.equal(emojiGotchi.name(), expectedName, "Name should be EmojiGotchi");
        Assert.equal(emojiGotchi.symbol(), expectedSymbol, "Symbol should be emg");
    }

    function testMinting() public {
        emojiGotchi.safeMint(address(this));
        uint256 tokenId = 0;

        Assert.equal(emojiGotchi.ownerOf(tokenId), address(this), "Owner should be this contract");
    }

    function testTokenIdIncrement() public {
        emojiGotchi.safeMint(address(this));  // Mint first token
        emojiGotchi.safeMint(address(this));  // Mint second token

        Assert.equal(emojiGotchi.ownerOf(0), address(this), "Owner of token 0 should be this contract");
        Assert.equal(emojiGotchi.ownerOf(1), address(this), "Owner of token 1 should be this contract");
    }
    
}
    