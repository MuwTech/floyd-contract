// scripts/deploy-all.js
const fs = require('fs');
const { ethers } = require("hardhat");
const args = require ("../arguments.js");

async function main() {
    const [deployer] = await ethers.getSigners();

    console.log(
        "Deploying contracts with the account:",
        deployer.address
    );

    console.log("Account balance:", (await deployer.getBalance()).toString());

    console.log("Deploying Floyd Factory contract...");
    const Floyd = await ethers.getContractFactory("Floyd");
    const floyd = await Floyd.deploy(
        args[0],
        args[1],
        args[2],
        args[3],
        args[4],
    );
    await floyd.deployed();
    const floyd = floyd.address;

    const file = `${process.cwd()}/data/addresses.json`;
    console.log(`Writing addresses to ${file}`);

    let addresses = {
        "floyd": floyd
    }
    let data = JSON.stringify(addresses);

    fs.writeFileSync(file, data);

    console.log("Floyd address:", floydAddress);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
