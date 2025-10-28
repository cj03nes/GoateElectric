pragma solidity v.0.8;


contract GateWayData( current pricefeed, future pricefeed, uint256) {
require(GateWayBridge);
require(GateWayTimeBridge);

current pricefeed:(
chainlink pricefeed & oracles,
viewer => btcchainexplorer, etherscan, coinmarketcap, coingecko,
onchain data,
contract addresses,
),
future pricefeeds:(
chainlink pricefeed & oracles,
viewer => btcchainexplorer, etherscan, coinmarketcap, coingecko,
onchain data,
contract addresses,
),
uint256:(
dateDeployed,
currentDate,
futureDate,
),

}
