const fs = require('fs');
const Web3 = require('web3');
const KCC = new Web3("https://rpc-mainnet.kcc.network");


//This Can Derive All Other ADDYS
const distributorContractAddy = "0xcB110fc3d8CaeBC81eCa54D77E29E97fbC7497f9";

test();
async function test() {
    console.log(await retrieveQuery(["PROTOCOL_STAKED_AMOUNT"]));
}

async function retrieveQuery(_query) {

    // - ["PROTOCOL_TOKEN_CONTRACT_ADDRESS"]
    // - ["STAKED_TOKEN_CONTRACT_ADDRESS"]
    // - ["DISTRIBUTOR_CONTRACT_ADDRESS"]
    // - ["CALCULATOR_CONTRACT_ADDRESS"]
    // - ["DEPOSITORY_CONTRACT_ADDRESS"]
    // - ["PROTOCOL_PRICE_USD"]
    // - ["PROTOCOL_PRICE_WKCS"]
    // - ["KCS_PRICE_USD"]
    // - ["PROTOCOL_DECIMALS"]
    // - ["STAKED_DECIMALS"]
    // - ["PROTOCOL_NEXT_REBASE"]               {Block Number}
    // - ["PROTOCOL_REBASE_AMOUNT"]             {per One Token}
    // - ["CURRENT_BLOCK"]
    // - ["SECCONDS_PER_BLOCK"]
    // - ["STAKED_TO_PROTOCOL"]                 {per One Token}
    // - ["PROTOCOL_TO_STAKED"]                 {per One Token}
    // - ["LIST_BONDS"]
    // - ["USER_BOND_TERMS", "User Address"]
    // - ["GET_BOND", "Bond Name"]
    // - ["BOND_PROFIT_PER_PROTOCOL", "Bond Name"]    {per One Token}
    // - ["STAKED_TOKEN_DECIMALS"]
    // - ["STAKED_TOKEN_SUPPLY"]
    // - ["PROTOCOL_TOKEN_SUPPLY"]
    // - ["PROTOCOL_STAKED_AMOUNT"]
    // - ["USER_DEPOSITORY_TOKEN_ALLOWANCE", "User Address", "Token Address"]
    // - ["USER_TOKEN_BALANCE", "User Address", "Token Address"]
    // - ["TOKEN_DECIMALS", "Token Address"]

    switch (_query[0]) {

        case "PROTOCOL_TOKEN_CONTRACT_ADDRESS":
            return (await (new KCC.eth.Contract(await retrieveABI('CALCULATOR_CONTRACT'), await retrieveQuery(['CALCULATOR_CONTRACT_ADDRESS']))).methods.protocolToken().call());
        case "STAKED_TOKEN_CONTRACT_ADDRESS":
            return (await (new KCC.eth.Contract(await retrieveABI('CALCULATOR_CONTRACT'), await retrieveQuery(['CALCULATOR_CONTRACT_ADDRESS']))).methods.stakedProtocolToken().call());
        case "DISTRIBUTOR_CONTRACT_ADDRESS":
            return (distributorContractAddy);
        case "CALCULATOR_CONTRACT_ADDRESS":
            return (await (new KCC.eth.Contract(await retrieveABI('DISTRIBUTOR_CONTRACT'), await retrieveQuery(['DISTRIBUTOR_CONTRACT_ADDRESS']))).methods.protocolCalculatorOracle().call());
        case "DEPOSITORY_CONTRACT_ADDRESS":
            return (await (new KCC.eth.Contract(await retrieveABI('DISTRIBUTOR_CONTRACT'), await retrieveQuery(['DISTRIBUTOR_CONTRACT_ADDRESS']))).methods.assetDepository().call());;
        case "PROTOCOL_PRICE_USD":
            let protocolInKCS = Number(await retrieveQuery(['PROTOCOL_PRICE_KCS']));
            let wkcsDecimals = 10 ** 18;
            let kcsPriceUSD = await retrieveQuery(['KCS_PRICE_USD']);
            return ((protocolInKCS / wkcsDecimals) * kcsPriceUSD);
        case "PROTOCOL_PRICE_WKCS":
            return (await (new KCC.eth.Contract(await retrieveABI('CALCULATOR_CONTRACT'), await retrieveQuery(['CALCULATOR_CONTRACT_ADDRESS']))).methods.protocolTokenPrice().call());
        case "KCS_PRICE_USD":
            let routerABI = [{ "inputs": [{ "internalType": "uint256", "name": "amountIn", "type": "uint256" }, { "internalType": "address[]", "name": "path", "type": "address[]" }], "name": "getAmountsOut", "outputs": [{ "internalType": "uint256[]", "name": "amounts", "type": "uint256[]" }], "stateMutability": "view", "type": "function" }];
            let kuswapRouter = new KCC.eth.Contract(routerABI, "0xa58350d6dee8441aa42754346860e3545cc83cda");
            let response = await kuswapRouter.methods.getAmountsOut(1000000000, ["0x4446fc4eb47f2f6586f9faab68b3498f86c07521", "0x980a5afef3d17ad98635f6c5aebcbaeded3c3430"]).call();
            return Number((response[1] / (10 ** 9)));
        case "PROTOCOL_DECIMALS":
            return (await (new KCC.eth.Contract(await retrieveABI('PROTOCOL_TOKEN_CONTRACT'), await retrieveQuery(['PROTOCOL_TOKEN_CONTRACT_ADDRESS']))).methods.decimals().call());
        case "STAKED_DECIMALS":
            return (await (new KCC.eth.Contract(await retrieveABI('STAKED_TOKEN_CONTRACT'), await retrieveQuery(['STAKED_TOKEN_CONTRACT_ADDRESS']))).methods.decimals().call());
        case "PROTOCOL_NEXT_REBASE":
            return (await (new KCC.eth.Contract(await retrieveABI('DISTRIBUTOR_CONTRACT'), await retrieveQuery(['DISTRIBUTOR_CONTRACT_ADDRESS']))).methods.stakingReward().call()).nextRewardBlock;
        case "PROTOCOL_REBASE_AMOUNT":
            return (await (new KCC.eth.Contract(await retrieveABI('DISTRIBUTOR_CONTRACT'), await retrieveQuery(['DISTRIBUTOR_CONTRACT_ADDRESS']))).methods.stakingReward().call()).protocolRewardAmount;
        case "CURRENT_BLOCK":
            return (await (new KCC.eth.Contract(await retrieveABI('DISTRIBUTOR_CONTRACT'), await retrieveQuery(['DISTRIBUTOR_CONTRACT_ADDRESS']))).methods.currentBlock().call());
        case "SECCONDS_PER_BLOCK":
            return 3;
        case "STAKED_TO_PROTOCOL":
            let oneStaked = 10 ** await retrieveQuery(['STAKED_DECIMALS'])
            return (await (new KCC.eth.Contract(await retrieveABI('STAKED_TOKEN_CONTRACT'), await retrieveQuery(['STAKED_TOKEN_CONTRACT_ADDRESS']))).methods.reserveToProtocol(oneStaked).call());
        case "PROTOCOL_TO_STAKED":
            let oneProtocol = 10 ** await retrieveQuery(['PROTOCOL_DECIMALS'])
            return (await (new KCC.eth.Contract(await retrieveABI('STAKED_TOKEN_CONTRACT'), await retrieveQuery(['STAKED_TOKEN_CONTRACT_ADDRESS']))).methods.reserveToProtocol(oneProtocol).call());
        case "LIST_BONDS":
            return (await (new KCC.eth.Contract(await retrieveABI('DISTRIBUTOR_CONTRACT'), await retrieveQuery(['DISTRIBUTOR_CONTRACT_ADDRESS']))).methods.listBonds().call());
        case "USER_BOND_TERMS":
            return (await (new KCC.eth.Contract(await retrieveABI('DISTRIBUTOR_CONTRACT'), await retrieveQuery(['DISTRIBUTOR_CONTRACT_ADDRESS']))).methods.listUserBonds(_query[1]).call());
        case "GET_BOND":
            return (await (new KCC.eth.Contract(await retrieveABI('DISTRIBUTOR_CONTRACT'), await retrieveQuery(['DISTRIBUTOR_CONTRACT_ADDRESS']))).methods.getBondByName(_query[1]).call());;
        case "BOND_PROFIT_PER_PROTOCOL":
            let pullBond = await retrieveQuery(['GET_BOND', _query[1]]);
            return (10 ** await retrieveQuery(['PROTOCOL_DECIMALS'])) * (pullBond.multiplier / 1000);
        case "STAKED_TOKEN_DECIMALS":
            return (await (new KCC.eth.Contract(await retrieveABI('STAKED_TOKEN_CONTRACT'), await retrieveQuery(['STAKED_TOKEN_CONTRACT_ADDRESS']))).methods.decimals().call());
        case "STAKED_TOKEN_SUPPLY":
            return (await (new KCC.eth.Contract(await retrieveABI('STAKED_TOKEN_CONTRACT'), await retrieveQuery(['STAKED_TOKEN_CONTRACT_ADDRESS']))).methods.totalSupply().call());
        case "PROTOCOL_TOKEN_SUPPLY":
            return (await (new KCC.eth.Contract(await retrieveABI('PROTOCOL_TOKEN_CONTRACT'), await retrieveQuery(['PROTOCOL_TOKEN_CONTRACT_ADDRESS']))).methods.totalSupply().call());
        case "PROTOCOL_STAKED_AMOUNT":
            return (await (new KCC.eth.Contract(await retrieveABI('STAKED_TOKEN_CONTRACT'), await retrieveQuery(['STAKED_TOKEN_CONTRACT_ADDRESS']))).methods.protocolReservoir().call());
        case "TOKEN_DECIMALS":
            return (await (new KCC.eth.Contract(await retrieveABI('STAKED_TOKEN_CONTRACT'), _query[1])).methods.protocolReservoir().call())

    }

}



async function retrieveABI(_query) {

    switch (_query) {

        case "PROTOCOL_TOKEN_CONTRACT":
            return JSON.parse(fs.readFileSync('./contractABI/ProtocolToken.json'));
        case "STAKED_TOKEN_CONTRACT":
            return JSON.parse(fs.readFileSync('./contractABI/StakedToken.json'));
        case "DISTRIBUTOR_CONTRACT":
            return JSON.parse(fs.readFileSync('./contractABI/Distributor.json'));
        case "CALCULATOR_CONTRACT":
            return JSON.parse(fs.readFileSync('./contractABI/Calculator.json'));
        case "DEPOSITORY_CONTRACT":
            return JSON.parse(fs.readFileSync('./contractABI/Depositor.json'));

    }


}


//Structs
/*

let Bond = {
    name,                   // - string - Bond Name
    tokenAddress,           // - address - Accepted Token To Deposit For Bond
    isAuthorized,           // - bool - Toggles Activation
    isLiquidityToken,       // - bool - Single Asset, or LP?
    isProtocolLiquidity,    // - bool - Is One Half Of The mainLiquidityPair The Protocol Token? 
    mainLiquidityPair,      // - address - Has To Be Paired with Protocol Token or Price Token, [Duplicate Address if LP Token]
    multiplier,             // - uint - Out of 1000, 500 = 50%, 250 = 25%
    vestingTermInBlocks,    // - uint - How Many Blocks Untill Fully Vested
    imageURL                // - string - Used For WebSite Generation [Bond Image]
}

let UserBondTerms = {
    name,                   // - string - Bond Name
    totalProtocolAmount,    // - uint - Total Amount Of Protocol Tokens Owed
    initialBondBlock,       // - uint - Intitially Bonded On What Block?
    finalBondBlock,         // - uint - Final Complete Vesting Block
    claimedAmount,          // - uint - How Much Protocol Tokens Have Been Claimed So Far
    totalProtocolProfit,    // - uint - Total Actual Protocol Token Profits
}

*/