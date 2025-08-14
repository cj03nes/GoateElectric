// scripts/exportFrontendEnv.js
// Exports .env contract addresses to a React-friendly .env file for build-time injection
const fs = require('fs');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../.env') });

const frontendEnvPath = path.join(__dirname, '../.env.frontend');
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

let output = '';
for (const key of keys) {
  if (process.env[key]) {
    output += `REACT_APP_${key}=${process.env[key]}\n`;
  }
}
fs.writeFileSync(frontendEnvPath, output);
console.log('.env.frontend generated for React build');
