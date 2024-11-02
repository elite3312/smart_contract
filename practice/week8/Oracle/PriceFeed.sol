// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
contract PriceFeed{
    AggregatorV3Interface internal dataFeed;
    constructor(){
        dataFeed=AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    }
    function getLatestEthPriceInUSD() public view returns(int){
        (,int answer,,,)=dataFeed.latestRoundData();
        return answer;
    }
}
