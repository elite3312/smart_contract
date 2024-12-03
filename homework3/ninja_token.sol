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
}