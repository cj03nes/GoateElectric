const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with:", deployer.address);

  const contracts = [
    "DeviceConnect",
    "Zeropoint",
    "ZeropointWifi",
    "ZeropointPhoneService",
    "ZeropointInsurance",
    "TheGoateToken",
    "GoateStaking",
    "TokenPairStaking",
    "p2pLendingAndBorrowing",
    "InstilledInteroperability",
    "CardWars",
    "HomeTeamBets",
    "GerastyxOpol",
    "Spades",
    "GerastyxPropertyNFT",
    "ContractRegistry"
  ];

  const deployed = {};

  for (const contract of contracts) {
    const Contract = await hre.ethers.getContractFactory(contract);
    const instance = await Contract.deploy();
    await instance.deployed();
    deployed[contract] = instance.address;
    console.log(`${contract} deployed to: ${instance.address}`);
  }

  console.log("Deployed addresses:", deployed);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});