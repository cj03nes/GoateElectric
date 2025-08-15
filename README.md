FeaturesUtilities: Device management, service purchasing (ZPE, ZPP, ZPW, ZGI).
DeFi: Buy, sell, transfer, stake, lend, borrow tokens.
Entertainment: Play games (CardWars, HomeTeamBets, etc.) and auction NFTs.
Authentication: Username/password and social logins (Google, Microsoft, X).
Dynamic Updates: Contract addresses/ABIs updated via ContractRegistry.
---

### Setup Instructions
1. **Images**:
   - **GoateElectricLogo.jpg**: Create a 12x12 pixel gold goat silhouette with electric bolts on a transparent background. Place in `src/images/`.
   - **background.jpg**: Create a 1920x1080 black-to-gold gradient with subtle lightning bolts. Place in `src/images/`.

2. **Firebase Setup**:
   - Create a Firebase project at `https://console.firebase.google.com`.
   - Enable Email/Password, Google, Microsoft, and Twitter (X) authentication in the Firebase console.
   - Update `.env` with Firebase config values.
   - Install Firebase SDK:
     ```bash
     npm install firebase
     ```

3. **Contract Deployment**:
   - Install Hardhat:
     ```bash
     npm install --save-dev hardhat @nomiclabs/hardhat-ethers dotenv
     ```
   - Compile contracts:
     ```bash
     npx hardhat compile
     ```
   - Deploy to Sepolia:
     ```bash
     npx hardhat run scripts/deploy.js --network sepolia
     ```
   - Update `.env` with deployed addresses and copy ABI JSON files from `artifacts/contracts/` to `src/abis/`.

4. **Contract Registry**:
   - After deploying `ContractRegistry.sol`, update it with contract addresses:
     ```javascript
     const registry = new ethers.Contract(
       getAddresses().ContractRegistry,
       getAbis().ContractRegistry,
       provider.getSigner()
     );
     await registry.updateAddress("DeviceConnect", "0x123...");
     await registry.updateAbi("DeviceConnect", JSON.stringify(require('./abis/DeviceConnect.json')));
     ```
   - Repeat for all contracts.

5. **Run Locally**:
   ```bash
   npm start

Deploy to Vercel:Push to https://github.com/cj03nes/GoateElectric.
Configure .env variables in Vercel dashboard.
Deploy via Vercel CLI:bash

vercel
