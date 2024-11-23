    // SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FurnitureSale {
    struct Furniture {
        uint id;
        string name;
        uint price;
        address payable seller;
        bool isSold;
    }

    mapping(uint => Furniture) public furnitureItems;
    uint public furnitureCount;

    event FurnitureListed(uint id, string name, uint price, address seller);
    event FurnitureSold(uint id, address buyer);

    function listFurniture(string memory _name, uint _price) public {
        require(_price > 0, "Price must be greater than zero");
        furnitureCount++;
        furnitureItems[furnitureCount] = Furniture(furnitureCount, _name, _price, payable(msg.sender), false);
        emit FurnitureListed(furnitureCount, _name, _price, msg.sender);
    }

    function buyFurniture(uint _id) public payable {
        Furniture storage furniture = furnitureItems[_id];
        require(_id > 0 && _id <= furnitureCount, "Furniture not found");
        require(msg.value == furniture.price, "Incorrect price");
        require(!furniture.isSold, "Furniture already sold");

        furniture.seller.transfer(msg.value);
        furniture.isSold = true;

        emit FurnitureSold(_id, msg.sender);
    }

    function getFurniture(uint _id) public view returns (uint, string memory, uint, address, bool) {
        Furniture memory furniture = furnitureItems[_id];
        return (furniture.id, furniture.name, furniture.price, furniture.seller, furniture.isSold);
    }
}