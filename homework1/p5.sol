// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;
contract RentalAgreement {
    address tenant; // Alice
    address  payable landlord; // Bob
    uint rentAmount;
    uint dueDate; // Monthly due date in Unix timestamp
    uint penaltyAmount;
    bool isPaid;
    constructor(address _tenant, address payable _landlord, uint _rentAmount,
        uint _dueDate, uint _penaltyAmount) {
        tenant = _tenant;
        landlord = _landlord;
        rentAmount = _rentAmount;
        dueDate = _dueDate;
        penaltyAmount = _penaltyAmount;
        isPaid = false;
    }

    // Function to make rent payment
    function payRent() public payable {
        require(msg.sender == tenant, "Only the tenant can pay the rent.");
        require(isPaid== false, "Only can pay once a month");
        uint _rentAmount = rentAmount;
        require( block.timestamp <= dueDate); {
            // Apply penalty
            _rentAmount+=penaltyAmount;
        }
        // Transfer rent to landlord
        landlord.transfer(_rentAmount);
        isPaid = true;
    }
    // Reset payment status at the start of each month
    function resetPaymentStatus() public {
        require( isPaid==true,"isPaid must be true" );
        isPaid = false;
    }
    // Function to check if rent is paid
    function checkPaymentStatus() public view returns (bool) {
        return isPaid;
    }
}