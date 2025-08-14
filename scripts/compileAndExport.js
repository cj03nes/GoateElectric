// scripts/compileAndExport.js
// Compiles contracts, exports ABIs to abis/, and updates .env with deployed addresses
const fs = require('fs');
const path = require('path');
const hre = require('hardhat');
require('dotenv').config();

const abisDir = path.join(__dirname, '../abis');
const envPath = path.join(__dirname, '../.env');

async function main() {
  // Compile contracts
  await hre.run('compile');

  // Export ABIs
  if (!fs.existsSync(abisDir)) fs.mkdirSync(abisDir);
  const artifactsDir = path.join(__dirname, '../artifacts/contracts');
  const contracts = fs.readdirSync(artifactsDir);
  for (const contractFolder of contracts) {
    const files = fs.readdirSync(path.join(artifactsDir, contractFolder));
    for (const file of files) {
      if (file.endsWith('.json')) {
        const artifact = require(path.join(artifactsDir, contractFolder, file));
        const abi = JSON.stringify(artifact.abi, null, 2);
        const name = file.replace('.json', '');
        fs.writeFileSync(path.join(abisDir, `${name}.json`), abi);
      }
    }
  }
  console.log('ABIs exported to abis/');
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
