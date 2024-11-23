# HW2

## Problem 1

- voting power
  - the voting power of a person is determined by the sum of donations he made to the fund.
- everyone can create a project
  - some variables are created to maintain the votes casted on each project
  - projects are identified by an integer ID, starting from 0
  - a project can be finalized once 50% voting power is voted on it
    - but only the owner can call finalize()
- logging
  - some state variables are created for logging finalized projects and donation received

## Problem 2

- ERC20 tokens are given to regular event participants
- ERC721 tokens(NFTs) are given to VIPs.
- fans
  - Loyalty Tiers:bronze, silver, gold
- activity
  - proof should be a url
  - associated with a token amount 
  - fan user can submit activity
  - owner can approve activity to give tokens to fans
- proposal
  - users can vote on proposals

## Problem 3

- struct aggreement holds details for each rental agreement.
- we use an array to hold multiple aggreements, each can have different landlord and tenants
  - for each aggreement, we use a state variable remaining_duration to record the remaining duration in the lease.
- only the tenants of each aggreement can pay, and they must pay the exact amount
- only the landlord can terminate the aggreement, and to do so the lease must be complete.
  - otherwise, we give the owner of the contract the right to terminate an aggreement in case of violation of aggreement.
  
## Problem 4

- any artist can create an auction
  - the nft will be minted and given to the artist
- buyers can place bids with ether
  - the bid will be transfer to the balance of the contract in doing so
- if the buyer is not the highest bidder, he can withdraw his bid.
- when the auction finishes, the buyer with the highest bid will have his money transfered to the artist.
  - the artist will transfer the NFT to the buyer.
  - all other buyers who do not win will have their money refunded
- debug info
  
  ```txt
  create auction : 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,catpic,http:meow,1,100000
  place bid : 1
  ```


## feedback

Question 1
25 pts
Full Marks
0 pts
No Marks
Comments
Grading:
Code Completeness: 5/5
All core functions (donate, submit, vote, finalize, view history) are implemented.

Correctness and Logic: 4/5
Voting power isn’t deducted after voting; potential double-counting issue. Lacks balance check before fund transfer.

Security and Best Practices: 3.5/5
Uses transfer() instead of call(); deducting 0.5 points. No contract balance check before disbursing funds.

Code Readability and Style: 5/5
Well-structured, clear comments, and effective use of descriptive names.

Use of Events: 5/5
Events are emitted for all major state changes.
22.5 / 25 pts
Question 2
25 pts
Full Marks
0 pts
No Marks
Comments
Code Completeness: Score: 4.5/5
Includes core features like token earning, verification, transfers, redemption, NFT issuance, and proposal voting. However, activity verification does not update the token balance upon approval.

Correctness and Logic: Score: 4/5
verifyActivity uses approve() instead of minting or transferring tokens directly to the fan, leading to potential logic errors. Token burning in redeemTokens lacks reward handling logic.

Security and Best Practices: Score: 3.5/5
verifyActivity lacks checks for re-verification. No access control on submitProposal or voteOnProposal, allowing anyone to spam proposals and votes.

Code Readability and Style: Score: 5/5
Code is clear, with well-defined structs, consistent naming, and effective use of OpenZeppelin libraries.

Use of Events and Transparency: Score: 4.5/5
Events are included for most key actions. However, missing events for token verification and proposal voting.
22.5 / 25 pts
Question 3
25 pts
Full Marks
0 pts
No Marks
Comments
Code Completeness: Score: 5/5
Implements agreement creation, rent payment, termination, and status retrieval as required.

Correctness and Logic: Score: 4.5/5
Minor issue: emit AgreementCreated should occur before incrementing agreementCount to avoid off-by-one error.

Security and Best Practices: Score: 4/5
Uses transfer() for Ether transfer, which can lead to gas issues. Prefer call(). Missing a reentrancy guard in payRent().

Code Readability and Style: Score: 4.5/5
Minor style issues (e.g., missing spaces, typos). remaining_duration could be renamed for clarity (e.g., remainingMonths).

Use of Events and Transparency: Score: 5/5
Good use of events for logging key actions.
23 / 25 pts
Question 4
25 pts
Full Marks
0 pts
No Marks
Comments
Code Completeness: Score: 5/5
The contract includes all primary features: auction creation, bid placement, bid withdrawal, and auction finalization, along with NFT minting and transfer.

Correctness and Logic: Score: 4/5
There are logical flaws in bid tracking using the bidders array, which could result in inefficiencies. Using an array to track bidders makes it difficult to handle duplicate entries, leading to potential refunds for incorrect addresses.

Security and Best Practices: Score: 4/5
Deducted points for using transfer() for refunds and payments. It is safer to use call() due to potential issues with gas limits. Additionally, _safeMint and safeTransferFrom should have checks for reentrancy.

Code Readability and Style: Score: 5/5
The code is well-structured, clear, and uses appropriate naming conventions. The use of comments helps in understanding the logic easily.

Use of Events and Transparency: Score: 5/5
All major actions are appropriately logged with events, providing good transparency throughout the contract's operations.