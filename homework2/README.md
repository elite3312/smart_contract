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

- proof should be a url
- Loyalty Tiers:bronze, silver, gold
- ERC20 tokens are given to regular event participants
- ERC721 tokens(NFTs) are given to VIPs.

## Problem 3

- struct aggreement holds details for each rental agreement.
- we use an array to hold multiple aggreements, each can have different landlord and tenants
  - for each aggreement, we use a state variable remaining_duration to record the remaining duration in the lease.
- only the tenants of each aggreement can pay, and they must pay the exact amount
- only the landlord can terminate the aggreement, and to do so the lease must be complete.
  - otherwise, we give the owner of the contract the right to terminate an aggreement in case of violation of aggreement.
  