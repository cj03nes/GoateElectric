markdown

# Goate Electric

A decentralized application for digital utilities, DeFi, and entertainment.

## Setup

1. **Install Dependencies**:
   ```bash
   npm install

2. Configure Environment:Create a .env file with contract addresses and Firebase config.
Example:

REACT_APP_DEVICE_CONNECT_ADDRESS=0x...
REACT_APP_FIREBASE_API_KEY=your_firebase_api_key
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/your_infura_key
PRIVATE_KEY=your_private_key

3. Compile and Deploy Contracts:bash

npx hardhat compile
npx hardhat run scripts/deploy.js --network sepolia

4. Run Locally:bash

npm start

5.Deploy to Vercel:Push to GitHub: git push origin main
Configure .env variables in Vercel dashboard.
Deploy via Vercel CLI or dashboard.
