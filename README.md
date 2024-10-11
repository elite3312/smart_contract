# smart_contract

## bookmark

modifier

## setup remix

```bash
npm install -g @remix-project/remixd
```

### using the local file system for remix

```bash
remixd
#Select connect to local host on the remix web editor
```

## project

- go on etherscan to find examples for smart contracts

## solidity notes

### gas

- every operation costs gas
  - gas estimates the cost of transaction, which can be evaluated in eth
- the gas limit should be reasonable so that transactions have enough gas to operate
- if gas limit is reached, transactions will roll back
- transaction cost- execution cost is the reward given to the validator

### state variables

- interacting with state variables is expensive in terms of gas, try to minimize this by using local caches.

### keywords

- the **view** keyword is used when a function does not modify the state variables
- a function that doesn't read or modify the variables of the state is called a **pure** function.
- **Memory** is used to store temporary data that is needed during the execution of a function. Calldata is used to store function arguments that are passed in from an external caller. Storage is used to store data permanently on the blockchain.
- **REVERT** will still undo all state changes, but it will be handled differently than an “invalid opcode” in two ways:
  - It will allow you to return a value.
  - It will refund any remaining gas to the caller.
- assert will not refund on failure
- **interface**就是拿來繼承用的
- A **modifier** is a special type of function that you use to modify the behavior of other functions. Modifiers allow you to add extra conditions or functionality to a function without having to rewrite the entire function.
  - the _ symbol
    - Before Function Execution:
      require(!locked, "No reentrancy"); checks if the locked variable is false. If locked is true, the function call is rejected with the message “No reentrancy”.
      locked = true; sets the locked variable to true, indicating that the function is now executing.
    - Function Body Execution:
      The _ symbol is where the actual function body is executed. When the function is called, the code inside the function replaces the _ symbol.
    - After Function Execution:
      locked = false; sets the locked variable back to false, allowing future calls to the function.
  - 有點像是幫function打補釘
- **internal** function就像private method
- **external** function只能給別人用

### contracts

- remember to add ether into contract balance when deploying

### ABI and bytecode

The byte code is the binary representation of the contract.
THe ABI is human readable text that represents the contract.

For example:

This contract results in this ABI.

```solidity
pragma solidity ^0.8.0;

contract SimpleStorage {
    uint256 storedData;

    function set(uint256 x) public {
        storedData = x;
    }

    function get() public view returns (uint256) {
        return storedData;
    }
}
```

```json
[
    {
        "constant": false,
        "inputs": [
            {
                "name": "x",
                "type": "uint256"
            }
        ],
        "name": "set",
        "outputs": [],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "constant": true,
        "inputs": [],
        "name": "get",
        "outputs": [
            {
                "name": "",
                "type": "uint256"
            }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
    }
]
```

## Dune SQL queries

- first step is to find the table name, e.g. **ethereum.transactions**

  ```txt
  select block_time from  ethereum.transactions LIMIT 3
  ```

- when you encounter errors during the query, you can look at the suggestions for position i.
- dashboard
  ```sql
  select  DATE_TRUNC('day', time ) as dt, count(*)as num_blocks
  from ethereum .blocks
  where time>=(DATE_TRUNC('day',CURRENT_TIMESTAMP)-INTERVAL '90' day )
  and time <=DATE_TRUNC('day',CURRENT_TIMESTAMP)
  group by 1 
  order by 1;
  ```
  - The COUNT() function returns the number of rows that matches a specified criterion.
  - the where clause limits the result to the most recent 90 days, and no later than today
  - grooup by 1 is to group by the first element of num_blocks, which is DATE_TRUNC('day', time )