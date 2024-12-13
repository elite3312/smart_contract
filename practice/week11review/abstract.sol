pragma solidity >=0.8.2 <0.9.0;

abstract contract Book {
    string internal material = "papyrus";

    constructor() {}
}

contract Encyclopedia is Book {
    constructor() {}

    function getMaterial() public view returns (string memory) {
        return material;//super goes 2 levels up
        //return super.material;
    }
}
//contract BookkEncyclopedia is Encyclopedia {
//    constructor() {}
//
//    function getMaterial1() public view returns (string memory) {
//        return super.material;
//    }
//}
