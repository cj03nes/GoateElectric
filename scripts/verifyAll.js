// scripts/verifyAll.js
// Verifies all deployed contracts on Etherscan using addresses from .env
const hre = require('hardhat');
require('dotenv').config();

async function main() {
  // Verify all contracts
  const keys = [
    'INSTILLED_INTEROPERABILITY_ADDRESS',
    'DEVICE_CONNECT_ADDRESS',
    'ZEROPOINT_ADDRESS',
    'ZEROPOINT_PHONE_SERVICE_ADDRESS',
    'ZEROPOINT_WIFI_ADDRESS',
    'THE_GOATE_TOKEN_ADDRESS',
    'USDMEDIATOR_ADDRESS',
    'THE_GOATE_CARD_ADDRESS',
    'PAY_WITH_CRYPTO_ADDRESS',
    'ZEROPOINT_DIGITAL_STOCK_NFT_ADDRESS',
    'TOKEN_PAIR_STAKING_ADDRESS',
    'P2P_LENDING_AND_BORROWING_ADDRESS',
    'GOATE_STAKING_ADDRESS',
    'GOATE_PIG_ADDRESS',
    'ZEROPOINT_INSURANCE_ADDRESS',
    'ZEROPOINT_SHIELD_ADDRESS',
    'GHOST_GOATE_ADDRESS',
    'CARD_WARS_ADDRESS',
    'HOME_TEAM_BETS_ADDRESS',
    'SPADES_ADDRESS',
    'GERASTYX_OPOL_ADDRESS',
    'GERASTYX_OPOL_PROPERTY_NFT_ADDRESS',
  ];
  for (const key of keys) {
    if (process.env[key]) {
      await hre.run('verify:verify', {
        address: process.env[key],
        constructorArguments: [],
      });
    }
  }
  console.log('Verification complete');
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
