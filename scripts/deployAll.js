// scripts/deployAll.js
// Deploys all contracts in contracts/ and updates .env with addresses
const fs = require('fs');
const path = require('path');
const hre = require('hardhat');
require('dotenv').config();

const envPath = path.join(__dirname, '../.env');

async function deploy(contractName, ...args) {
  const Contract = await hre.ethers.getContractFactory(contractName);
  const contract = await Contract.deploy(...args);
  await contract.deployed();
  return contract.address;
}

async function updateEnv(key, value) {
  let env = fs.readFileSync(envPath, 'utf8');
  const regex = new RegExp(`^${key}=.*$`, 'm');
  if (env.match(regex)) {
    env = env.replace(regex, `${key}=${value}`);
  } else {
    env += `\n${key}=${value}`;
  }
  fs.writeFileSync(envPath, env);
}

async function main() {
  // Deploy all contracts and update .env
  const addresses = {};
  addresses.INSTILLED_INTEROPERABILITY_ADDRESS = await deploy('InstilledInteroperability');
  addresses.DEVICE_CONNECT_ADDRESS = await deploy('DeviceConnect');
  addresses.ZEROPOINT_ADDRESS = await deploy('Zeropoint');
  addresses.ZEROPOINT_PHONE_SERVICE_ADDRESS = await deploy('ZeropointPhoneService');
  addresses.ZEROPOINT_WIFI_ADDRESS = await deploy('ZeropointWifi');
  addresses.THE_GOATE_TOKEN_ADDRESS = await deploy('TheGoateToken');
  addresses.USDMEDIATOR_ADDRESS = await deploy('USDMediator');
  addresses.THE_GOATE_CARD_ADDRESS = await deploy('TheGoateCard');
  addresses.PAY_WITH_CRYPTO_ADDRESS = await deploy('PayWithCrypto');
  addresses.ZEROPOINT_DIGITAL_STOCK_NFT_ADDRESS = await deploy('ZeropointDigitalStockNFT');
  addresses.TOKEN_PAIR_STAKING_ADDRESS = await deploy('TokenPairStaking');
  addresses.P2P_LENDING_AND_BORROWING_ADDRESS = await deploy('Lending');
  addresses.GOATE_STAKING_ADDRESS = await deploy('GoateStaking');
  addresses.GOATE_PIG_ADDRESS = await deploy('GoatePig');
  addresses.ZEROPOINT_INSURANCE_ADDRESS = await deploy('ZeropointInsurance');
  addresses.ZEROPOINT_SHIELD_ADDRESS = await deploy('ZeropointShield');
  addresses.GHOST_GOATE_ADDRESS = await deploy('GhostGoate');
  addresses.CARD_WARS_ADDRESS = await deploy('War');
  addresses.HOME_TEAM_BETS_ADDRESS = await deploy('HomeTeamBets');
  addresses.SPADES_ADDRESS = await deploy('Spades');
  addresses.GERASTYX_OPOL_ADDRESS = await deploy('GerastyxOpol');
  addresses.GERASTYX_OPOL_PROPERTY_NFT_ADDRESS = await deploy('GerastyxPropertyNFT');
  for (const [key, value] of Object.entries(addresses)) {
    await updateEnv(key, value);
  }
  console.log('Deployed all contracts and updated .env');
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
