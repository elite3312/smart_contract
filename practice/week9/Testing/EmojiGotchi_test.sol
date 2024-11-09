// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "./EmojiGotchi.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract testSuite {

    EmojiGotchi emojiGotchi;

    address acc0;
    address acc2;
    function beforeAll() public {
        emojiGotchi = new EmojiGotchi();
        acc0=TestsAccounts.getAccount(0);
        
        acc2=TestsAccounts.getAccount(2);
    }

    function testInitialNameAndSymbol() public {
        string memory expectedName = "EmojiGotchi";
        string memory expectedSymbol = "emg";

        Assert.equal(emojiGotchi.name(), expectedName, "Name should be EmojiGotchi");
        Assert.equal(emojiGotchi.symbol(), expectedSymbol, "Symbol should be emg");
    }

    function testMinting() public {
        emojiGotchi.safeMint(acc0);
        uint256 tokenId = 0;

        Assert.equal(emojiGotchi.ownerOf(tokenId), acc0, "Owner should be this contract");
    }

    function testTokenIdIncrement() public {
        emojiGotchi.safeMint(acc0);  // Mint first token
        emojiGotchi.safeMint(acc2);  // Mint second token

        Assert.equal(emojiGotchi.ownerOf(0), acc0, "Owner of token 0 should be this contract");
        Assert.equal(emojiGotchi.ownerOf(2), acc2, "Owner of token 1 should be this contract");
    }
    
}
    