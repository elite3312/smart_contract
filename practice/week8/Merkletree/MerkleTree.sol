// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract MerkleProof {
    function makeHash(string memory transaction) public pure returns (bytes32) {
        // Implement the makeHash function to return the hash value of a transaction
        return keccak256(abi.encodePacked(transaction));
    }
    function verify(
        bytes32[] memory proof,/*proof array 是我需要用到的其他hash, array 的order 是從下到上*/
        bytes32 root,/*root is given*/
        bytes32 leaf,
        uint256 index/*index of the leaf to verify*/
    ) public pure returns (bool) {
        /*this function will verify a leaf by computing the root hash from this leaf*/
        
        bytes32 hash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (index % 2 == 0) {
                hash = keccak256(abi.encodePacked(hash, proofElement));
            } else {
                hash = keccak256(abi.encodePacked(proofElement, hash));
            }
            /*
                    root
                 /        \
              proof_elem     5
             /  \           / \ 
            0   1          2  proof_elem
            */

            index = index / 2;
        }

        return hash == root;
    }
}

contract TestMerkleProof is MerkleProof {
    bytes32[] public hashes;

    constructor() {
        string[4] memory transactions =
            ["alice -> bob", "bob -> dave", "carol -> alice", "dave -> bob"];

        for (uint256 i = 0; i < transactions.length; i++) {
            hashes.push(keccak256(abi.encodePacked(transactions[i])));
        }

        uint256 n = transactions.length;
        uint256 offset = 0;

        while (n > 0) {
            for (uint256 i = 0; i < n - 1; i += 2) {//notice i+=2!
                hashes.push(
                    keccak256(
                        abi.encodePacked(
                            hashes[offset + i], hashes[offset + i + 1]
                        )
                    )
                );
            }
            offset += n;
            n = n / 2;
        }
        /*
           6
          4 5
        0 1 2 3
        */
    }

    function getRoot() public view returns (bytes32) {
        return hashes[hashes.length - 1];
    }

    /* verify
    3rd leaf
    0xdca3326ad7e8121bf9cf9c12333e6b2271abe823ec9edfe42f813b1e768fa57b

    root
    0xcc086fcc038189b4641db2cc4f1de3bb132aefbd65d510d817591550937818c7

    index
    2

    proof
    0x8da9e1c820f9dbd1589fd6585872bc1063588625729e7ab0797cfc63a00bd950
    0x995788ffc103b987ad50f5e5707fd094419eb12d9552cc423bd0cd86a3861433
    */
}
