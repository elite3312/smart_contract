// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract NinjaToken is ERC20 {
    address owner;
    constructor() ERC20("NinjaToken", "NT") {
        owner=msg.sender;
        _mint(msg.sender, 1000000 * (10 ** uint256(decimals())));
    }

    //burnable
    function burn(uint256 amount) public {
    _burn(msg.sender, amount);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    //mintable
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
    bool private _paused;

    //pausable
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    function pause() public onlyOwner {
        _paused = true;
    }

    function unpause() public onlyOwner {
        _paused = false;
    }

    function transfer(address recipient, uint256 amount) public override whenNotPaused returns (bool) {
        return super.transfer(recipient, amount);
    }

    // NinjaDual

    /*
    We introduce a feature called called NinjaDual, where you can enter the address of another person holding Ninja Tokens, 
    and his balance is at least 1000 tokens, you two can go to a dual. As in, either you can grab half of his tokens, or 
    he can have half of yours.
    */
    function ninjaDual(address opponent) public whenNotPaused {
        require(balanceOf(msg.sender) >= 1000 * (10 ** uint256(decimals())), "You need at least 1000 tokens to duel");
        require(balanceOf(opponent) >= 1000 * (10 ** uint256(decimals())), "Opponent needs at least 1000 tokens to duel");

        uint256 halfTokens = balanceOf(opponent) / 2;
        uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, blockhash(block.number - 1), msg.sender, opponent))) % 2;

        if (random == 0) {
            _transfer(opponent, msg.sender, halfTokens);
        } else {
            _transfer(msg.sender, opponent, halfTokens);
        }
    }
}