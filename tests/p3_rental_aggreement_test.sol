// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "remix_tests.sol"; // this import is automatically injected by Remix.
import "remix_accounts.sol";
import "../homework2/p3_rental_aggreement.sol";

contract RentalAgreementManagementTest {
    RentalAgreementManagement rentalAgreementManagement;
    address owner;
    address payable landlord;
    address tenant;

    function beforeAll() public {
        owner = TestsAccounts.getAccount(0);
        landlord = payable(TestsAccounts.getAccount(1));
        tenant = TestsAccounts.getAccount(2);
        rentalAgreementManagement = new RentalAgreementManagement();
    }

    function testCreateAgreement() public {
        rentalAgreementManagement.createAgreement(landlord, tenant, 1000, 12);
        (address payable _landlord, address _tenant, uint256 rentAmount, , uint256 duration, uint256 remaining_duration, bool active) = rentalAgreementManagement.agreements(0);
        Assert.equal(_landlord, landlord, "Landlord should be correct");
        Assert.equal(_tenant, tenant, "Tenant should be correct");
        Assert.equal(rentAmount, 1000 , "Rent amount should be correct");
        Assert.equal(duration, 12, "Duration should be correct");
        Assert.equal(remaining_duration, 12, "Remaining duration should be correct");
        Assert.equal(active, true, "Agreement should be active");
    }
    /// #sender: account-2
    /// #value: 1000 
    function testPayRent() public payable {
        // Ensure the correct value is sent
        Assert.equal(msg.value, 1000 , "Value should be 1000");

        // Create an agreement
        rentalAgreementManagement.createAgreement(landlord, tenant, 1000, 12);

        // Pay rent using the tenant account
        address tenantAccount = TestsAccounts.getAccount(2);
        rentalAgreementManagement.payRent{value: 1000 }(0);

        // Check remaining duration
        (, , , , , uint256 remaining_duration, ) = rentalAgreementManagement.agreements(0);
        Assert.equal(remaining_duration, 11, "Remaining duration should be decremented");

        // Check payment history
        uint256[] memory payments = rentalAgreementManagement.getPaymentHistory(0);
        Assert.equal(payments.length, 1, "Payment history should have one entry");
    }

    function testTerminateAgreement() public {
        rentalAgreementManagement.createAgreement(landlord, tenant, 1000, 12);
        rentalAgreementManagement.terminateAgreement(0);
        (, , , , , , bool active) = rentalAgreementManagement.agreements(0);
        Assert.equal(active, false, "Agreement should be terminated");
    }

    function testGetAgreementStatus() public {
        rentalAgreementManagement.createAgreement(landlord, tenant, 1000, 12);
        string memory status = rentalAgreementManagement.getAgreementStatus(1);
        Assert.equal(status, "Active", "Agreement should be active");
       // rentalAgreementManagement.terminateAgreement(0);
        //status = rentalAgreementManagement.getAgreementStatus(0);
        //Assert.equal(status, "Terminated", "Agreement should be terminated");
    }
}