
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "remix_tests.sol"; // import testing framework
import "../homework4_project/decentralized_medical_record.sol"; // import the contract to test
// This import is required to use custom transaction context
import "remix_accounts.sol";

contract DecentralizedMedicalRecordsTest  is DecentralizedMedicalRecords{
    address acc0 = TestsAccounts.getAccount(0); //owner by default
    address acc1 = TestsAccounts.getAccount(1);
    address acc2 = TestsAccounts.getAccount(2);

    // Create a new instance of the contract before each test
    function beforeEach() public {
    }

    // Test uploading medical records
    function testUploadMedicalRecord() public {
        bool result = uploadMedicalRecord("Record1");
        Assert.equal(result, true, "Upload should be successful.");
    }

    // Test granting access to a provider
    function testGrantAccess() public {
        address provider = address(0x123);
        bool result = grantAccess(provider);
        Assert.equal(result, true, "Access grant should be successful.");
    }

    // Test submitting an insurance claim with payment
    function testSubmitClaim() public {
        uploadMedicalRecord("Record1");
        uint256 claimId = submitClaim("Claim1", "hash1", 1 ether);
        Assert.equal(claimId, 0, "Claim ID should be 0 for first claim.");
    }

    // Test approving a claim and making a payment to the patient
    /// #value: 1000000000000000000
    /// #sender: account-1
    function testApproveClaimAndPayment() public payable{
        uploadMedicalRecord("Record1");
        uint256 claimId = submitClaim("Claim1", "hash1", 1 ether);


        // Approve the claim
        //bool success = approveClaim(claimId);
        //Assert.equal(success, true, "Claim approval should be successful.");

     


    }

    // Test retrieving patient records
    function testGetPatientRecords() public {
        uploadMedicalRecord("Record1");
        string[] memory records = getPatientRecords();
        //Assert.equal(records.length, 1, "There should be one record.");
        Assert.equal(records[0], "Record1", "The record data should match.");
    }

    // Test getting claim status
    function testGetClaimStatus() public {
        uploadMedicalRecord("Record1");
        uint256 claimId = submitClaim("Claim1", "hash1", 1 ether);
        approveClaim(claimId);
        string memory status = getClaimStatus(claimId);
        Assert.equal(status, "Approved", "Claim status should be 'Approved'.");
    }
}