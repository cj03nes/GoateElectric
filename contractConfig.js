// contractConfig.js
// Configuration for Goate Electric smart contract addresses and ABIs
// Loads from environment variables at build time and supports runtime updates

import { ethers } from 'ethers';

// Initial contract addresses from environment variables (build-time)
const initialAddresses = {
  DeviceConnect: process.env.REACT_APP_DEVICE_CONNECT_ADDRESS || '0x0000000000000000000000000000000000000000',
  Zeropoint: process.env.REACT_APP_ZEROPOINT_ADDRESS || '0x0000000000000000000000000000000000000000',
  ZeropointWifi: process.env.REACT_APP_ZEROPOINT_WIFI_ADDRESS || '0x0000000000000000000000000000000000000000',
  ZeropointPhoneService: process.env.REACT_APP_ZEROPOINT_PHONE_SERVICE_ADDRESS || '0x0000000000000000000000000000000000000000',
  ZeropointInsurance: process.env.REACT_APP_ZEROPOINT_INSURANCE_ADDRESS || '0x0000000000000000000000000000000000000000',
  TheGoateToken: process.env.REACT_APP_THE_GOATE_TOKEN_ADDRESS || '0x0000000000000000000000000000000000000000',
  GoateStaking: process.env.REACT_APP_GOATE_STAKING_ADDRESS || '0x0000000000000000000000000000000000000000',
  TokenPairStaking: process.env.REACT_APP_TOKEN_PAIR_STAKING_ADDRESS || '0x0000000000000000000000000000000000000000',
  p2pLendingAndBorrowing: process.env.REACT_APP_P2P_LENDING_BORROWING_ADDRESS || '0x0000000000000000000000000000000000000000',
  InstilledInteroperability: process.env.REACT_APP_INSTILLED_INTEROPERABILITY_ADDRESS || '0x0000000000000000000000000000000000000000',
  CardWars: process.env.REACT_APP_CARD_WARS_ADDRESS || '0x0000000000000000000000000000000000000000',
  HomeTeamBets: process.env.REACT_APP_HOME_TEAM_BETS_ADDRESS || '0x0000000000000000000000000000000000000000',
  GerastyxOpol: process.env.REACT_APP_GERASTYX_OPOL_ADDRESS || '0x0000000000000000000000000000000000000000',
  Spades: process.env.REACT_APP_SPADES_ADDRESS || '0x0000000000000000000000000000000000000000',
  GerastyxPropertyNFT: process.env.REACT_APP_GERASTYX_PROPERTY_NFT_ADDRESS || '0x0000000000000000000000000000000000000000',
};

// Initial ABIs from local JSON files (build-time)
const initialAbis = {
  DeviceConnect: require('./abis/DeviceConnect.json'),
  Zeropoint: require('./abis/Zeropoint.json'),
  ZeropointWifi: require('./abis/ZeropointWifi.json'),
  ZeropointPhoneService: require('./abis/ZeropointPhoneService.json'),
  ZeropointInsurance: require('./abis/ZeropointInsurance.json'),
  TheGoateToken: require('./abis/TheGoateToken.json'),
  GoateStaking: require('./abis/GoateStaking.json'),
  TokenPairStaking: require('./abis/TokenPairStaking.json'),
  p2pLendingAndBorrowing: require('./abis/p2pLendingAndBorrowing.json'),
  InstilledInteroperability: require('./abis/InstilledInteroperability.json'),
  CardWars: require('./abis/CardWars.json'),
  HomeTeamBets: require('./abis/HomeTeamBets.json'),
  GerastyxOpol: require('./abis/GerastyxOpol.json'),
  Spades: require('./abis/Spades.json'),
  GerastyxPropertyNFT: require('./abis/GerastyxPropertyNFT.json'),
};

// State to hold current addresses and ABIs
let addresses = { ...initialAddresses };
let abis = { ...initialAbis };

// Function to update addresses and ABIs at runtime
export const updateContractConfig = async () => {
  try {
    // Example: Fetch updated addresses/ABIs from a server
    const response = await fetch('https://api.goateelectric.com/contracts', {
      headers: { 'Content-Type': 'application/json' },
    });
    const data = await response.json();

    // Update addresses if provided
    if (data.addresses) {
      addresses = { ...addresses, ...data.addresses };
    }

    // Update ABIs if provided
    if (data.abis) {
      for (const [contract, abi] of Object.entries(data.abis)) {
        try {
          // Validate ABI
          ethers.utils.Interface(abi);
          abis[contract] = abi;
        } catch (error) {
          console.error(`Invalid ABI for ${contract}:`, error);
        }
      }
    }

    console.log('Contract config updated:', addresses, abis);
  } catch (error) {
    console.error('Failed to update contract config:', error);
  }
};

// Function to get current addresses
export const getAddresses = () => ({ ...addresses });

// Function to get current ABIs
export const getAbis = () => ({ ...abis });

// Initialize with a fetch on load (optional)
if (typeof window !== 'undefined') {
  updateContractConfig();
}

export { addresses, abis };