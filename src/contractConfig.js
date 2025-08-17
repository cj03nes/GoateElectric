import { ethers } from 'ethers';

// Initial contract addresses from environment variables
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
  ContractRegistry: process.env.REACT_APP_CONTRACT_REGISTRY_ADDRESS || '0x0000000000000000000000000000000000000000',
};

// Initial ABIs from local JSON files
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
  ContractRegistry: require('./abis/ContractRegistry.json'),
};

// State to hold current addresses and ABIs
let addresses = { ...initialAddresses };
let abis = { ...initialAbis };

// Function to update addresses and ABIs from ContractRegistry
export const updateContractConfig = async () => {
  try {
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const registry = new ethers.Contract(
      initialAddresses.ContractRegistry,
      initialAbis.ContractRegistry,
      provider
    );
    const contractNames = Object.keys(initialAddresses);
    for (const name of contractNames) {
      if (name === 'ContractRegistry') continue;
      const addr = await registry.getAddress(name);
      if (addr !== '0x0000000000000000000000000000000000000000') {
        addresses[name] = addr;
      }
      const abi = await registry.getAbi(name);
      if (abi) {
        try {
          ethers.utils.Interface(JSON.parse(abi));
          abis[name] = JSON.parse(abi);
        } catch (error) {
          console.error(`Invalid ABI for ${name}:`, error);
        }
      }
    }
    console.log('Contract config updated:', addresses);
  } catch (error) {
    console.error('Failed to update contract config:', error);
  }
};

// Function to get current addresses
export const getAddresses = () => ({ ...addresses });

// Function to get current ABIs
export const getAbis = () => ({ ...abis });

// Initialize with a fetch on load (client-side only)
if (typeof window !== 'undefined') {
  updateContractConfig();
  setInterval(updateContractConfig, 60000); // Update every minute
}

export { addresses, abis };