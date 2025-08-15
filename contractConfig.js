// This file is auto-generated. Do not edit manually.
// It loads contract addresses and ABIs from environment variables (for build-time) and provides a runtime fallback.



export const addresses = {
  DeviceConnect: '0x...',
  Zeropoint: '0x...',
  ZeropointWifi: '0x...',
  ZeropointPhoneService: '0x...',
  ZeropointInsurance: '0x...',
  TheGoateToken: '0x...',
  GoateStaking: '0x...',
  TokenPairStaking: '0x...',
  p2pLendingAndBorrowing: '0x...',
  InstilledInteroperability: '0x...',
  CardWars: '0x...',
  HomeTeamBets: '0x...',
  GerastyxOpol: '0x...',
  Spades: '0x...',
  GerastyxPropertyNFT: '0x...',
};

export const abis = {
  DeviceConnect: [...], // ABI from DeviceConnect.sol
  Zeropoint: [...], // ABI from Zeropoint.sol
  ZeropointWifi: [...], // ABI from ZeropointWifi.sol
  ZeropointPhoneService: [...], // ABI from ZeropointPhoneService.sol
  ZeropointInsurance: [...], // ABI from ZeropointInsurance.sol
  TheGoateToken: [...], // ABI from TheGoateToken.sol
  GoateStaking: [...], // ABI from GoateStaking.sol
  TokenPairStaking: [...], // ABI from TokenPairStaking.sol
  p2pLendingAndBorrowing: [...], // ABI from p2pLendingAndBorrowing.sol
  InstilledInteroperability: [...], // ABI from InstilledInteroperability.sol
  CardWars: [...], // ABI from CardWars.sol
  HomeTeamBets: [...], // ABI from HomeTeamBets.sol
  GerastyxOpol: [...], // ABI from GerastyxOpol.sol
  Spades: [...], // ABI from Spades.sol
  GerastyxPropertyNFT: [...], // ABI from GerastyxPropertyNFT.sol
};





const addresses = {
  InstilledInteroperability: process.env.REACT_APP_INSTILLED_INTEROPERABILITY_ADDRESS || '',
  DeviceConnect: process.env.REACT_APP_DEVICE_CONNECT_ADDRESS || '',
  // ...add other contracts as needed
};

const abis = {
  InstilledInteroperability: require('./abis/InstilledInteroperability.json'),
  DeviceConnect: require('./abis/DeviceConnect.json'),
  // ...add other contracts as needed
};

export { addresses, abis };
