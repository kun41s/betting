async function main() {
    const BetContract = await ethers.getContractFactory("Bet");
    const bet = await BetContract.deploy();
    console.log("Contract Address ", bet.address);
}

main()
    .then(() => process.exit(0))
    .catch((e) => {
        console.log(e);
        process.exit(1);
    });