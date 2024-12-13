// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BigCat {
    event BigCatRoar(string memorymessage);

    function roar(uint256 level) public pure returns (string memory result) {//the problem is the pure
        require(level >= 0, "Not a valid Roar");
        require(level != 1, "Meow is not Roar");
        emit BigCatRoar("Valid Roar of Big Cat");
        return "Valid Roar of Big Cat";
    }
}

contract Lion is BigCat {
    event LionRoar(string message);
    BigCat public bigCat;

    constructor() {
        bigCat = new BigCat();
    }

    function roarCall(uint256 _i) public {
        try bigCat.roar(_i) returns (string memory result) {
            emit LionRoar(result);
        } catch {
            emit LionRoar("Roar call failed");
        }
    }
}
