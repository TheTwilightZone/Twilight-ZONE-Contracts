const fs = require('fs');
const Web3 = require('web3');
const KCC = new Web3("https://rpc-mainnet.kcc.network");


//This Can Derive All Other ADDYS
const distributorContractAddy = "0xcB110fc3d8CaeBC81eCa54D77E29E97fbC7497f9";

test();
async function test() {
    console.log(await retrieveQuery(["USER_PROFILE", "0xA45464bDDf0956D92D3C9d2DDDe7B8CB8b22ebFD"]));
}

async function retrieveQuery(query) {

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

    switch (query[0]) {

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
            return (await (new KCC.eth.Contract(await retrieveABI('DISTRIBUTOR_CONTRACT'), await retrieveQuery(['DISTRIBUTOR_CONTRACT_ADDRESS']))).methods.listUserBonds(query[1]).call());
        case "GET_BOND":
            return (await (new KCC.eth.Contract(await retrieveABI('DISTRIBUTOR_CONTRACT'), await retrieveQuery(['DISTRIBUTOR_CONTRACT_ADDRESS']))).methods.getBondByName(query[1]).call());
        case "BOND_PROFIT_PER_PROTOCOL":
            let pullBond = await retrieveQuery(['GET_BOND', query[1]]);
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
            return (await (new KCC.eth.Contract(await retrieveABI('STAKED_TOKEN_CONTRACT'), query[1])).methods.protocolReservoir().call())
        case "USER_PROTOCOL_TOKEN_BALANCE":
            let bal = (await (new web3userctx.eth.Contract(await retrieveABI('PROTOCOL_TOKEN_CONTRACT'), await retrieveQuery(['PROTOCOL_TOKEN_CONTRACT_ADDRESS']))).methods.balanceOf(query[1]).call());
            return bal / (10 ** await retrieveQuery(['PROTOCOL_DECIMALS']));
        case "USER_STAKED_TOKEN_BALANCE":
            let sBal = (await (new web3userctx.eth.Contract(await retrieveABI('STAKED_TOKEN_CONTRACT'), await retrieveQuery(['STAKED_TOKEN_CONTRACT_ADDRESS']))).methods.balanceOf(query[1]).call());
            return sBal / (10 ** await retrieveQuery(['STAKED_DECIMALS']));
        case "USER_TOKEN_BALANCE":
            return (await (new KCC.eth.Contract(await retrieveABI('PROTOCOL_TOKEN_CONTRACT'), query[2])).methods.balanceOf(query[1]).call());;
        case "STAKE_APY":
            let baseToken = (10 ** await retrieveQuery(["PROTOCOL_DECIMALS"]));
            let profit = await retrieveQuery(["PROTOCOL_REBASE_AMOUNT"])
            let compoundTimeInSecconds = (await retrieveQuery(["PROTOCOL_REBASE_BLOCK_AMOUNT"]) * await retrieveQuery(["SECCONDS_PER_BLOCK"]));
            let percentage = ((profit * baseToken) / 10000);
            let periodsPerYear = (31536000 / compoundTimeInSecconds);
            return (baseToken * (Math.pow((1 + (percentage / periodsPerYear)), (periodsPerYear * 1))));
        case "PROTOCOL_REBASE_BLOCK_AMOUNT":
            return (await (new KCC.eth.Contract(await retrieveABI('DISTRIBUTOR_CONTRACT'), await retrieveQuery(['DISTRIBUTOR_CONTRACT_ADDRESS']))).methods.stakingReward().call()).everyBlockAmount;
        case "USER_PROFILE":
            let profile = new userProfile("value");
            profile.USER_ADDRESS = query[1];
            profile.ZONE_BALANCE_CONTRACT = (await retrieveQuery(["USER_TOKEN_BALANCE", await retrieveQuery(['PROTOCOL_TOKEN_CONTRACT_ADDRESS']), profile.USER_ADDRESS]));
            profile.ZONE_BALANCE_DECIMAL = ((await retrieveQuery(["PROTOCOL_DECIMALS"])) ** profile.ZONE_BALANCE_CONTRACT);
            profile.TWILIGHT_BALANCE_CONTRACT = (await retrieveQuery(["USER_TOKEN_BALANCE", await retrieveQuery(['STAKED_TOKEN_CONTRACT_ADDRESS']), profile.USER_ADDRESS]));
            profile.TWILIGHT_BALANCE_DECIMAL = ((await retrieveQuery(["STAKED_DECIMALS"])) ** profile.TWILIGHT_BALANCE_CONTRACT);
            
            if(await (new KCC.eth.Contract(await retrieveABI('PROTOCOL_TOKEN_CONTRACT'), await retrieveQuery(['PROTOCOL_TOKEN_CONTRACT_ADDRESS']))).methods.allowance(profile.USER_ADDRESS, await retrieveQuery(["DEPOSITORY_CONTRACT_ADDRESS"])).call() > 0){
                profile.IS_ZONE_APPROVED = true
            }else{profile.IS_ZONE_APPROVED = false}
            if(await (new KCC.eth.Contract(await retrieveABI('PROTOCOL_TOKEN_CONTRACT'), await retrieveQuery(['STAKED_TOKEN_CONTRACT_ADDRESS']))).methods.allowance(profile.USER_ADDRESS, await retrieveQuery(["DEPOSITORY_CONTRACT_ADDRESS"])).call() > 0){
                profile.IS_TWILIGHT_APPROVED = true
            }else{profile.IS_TWILIGHT_APPROVED = false}
            profile.ZONE_APPROVAL_AMOUNT_CONTRACT = (new KCC.eth.Contract(await retrieveABI('PROTOCOL_TOKEN_CONTRACT'), await retrieveQuery(['PROTOCOL_TOKEN_CONTRACT_ADDRESS']))).methods.allowance(profile.USER_ADDRESS, await retrieveQuery(["DEPOSITORY_CONTRACT_ADDRESS"])).call();
            profile.ZONE_APPROVAL_AMOUNT_DECIMAL = ((await retrieveQuery(["PROTOCOL_DECIMALS"])) ** profile.ZONE_APPROVAL_AMOUNT_CONTRACT);
            profile.TWILIGHT_APPROVAL_AMOUNT_CONTRACT = (new KCC.eth.Contract(await retrieveABI('PROTOCOL_TOKEN_CONTRACT'), await retrieveQuery(['STAKEDPROTOCOL_TOKEN_CONTRACT_ADDRESS']))).methods.allowance(profile.USER_ADDRESS, await retrieveQuery(["DEPOSITORY_CONTRACT_ADDRESS"])).call();
            profile.TWILIGHT_APPROVAL_AMOUNT_DECIMAL = ((await retrieveQuery(["STAKED_DECIMALS"])) ** profile.TWILIGHT_APPROVAL_AMOUNT_CONTRACT);

            profile.DEPOSITORY_ADDRESS = await retrieveQuery(['DEPOSITORY_CONTRACT_ADDRESS']);
            profile.DEPOSITORY_ABI = await retrieveABI('DEPOSITORY_CONTRACT');
            profile.DEPOSITORY_ADDRESS = await retrieveQuery(['DIRSTRIBUTOR_CONTRACT_ADDRESS']);
            profile.DEPOSITORY_ABI = await retrieveABI('DIRSTRIBUTOR_CONTRACT');
            profile.PROTOCOL_ABI = await retrieveABI('PROTOCOL_CONTRACT');
            profile.PROTOCOL_ADDRESS =  await retrieveABI('PROTOCOL_CONTRACT');

            profile.BOND_LIST = (await (new Web3.eth.Contract(profile.DIRSTRIBUTOR_ABI, profile.DIRSTRIBUTOR_ADDRESS)).methods.listUserBonds(profile.USER_ADDRESS).call());

        return profile;
    }

}


async function retrieveABI(query){

    switch (query) {

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

class userBond{
    constructor(BOND_NAME,
    BOND_TOKEN_ADDRESS,
    ZONE_VALUE_DEPOSITED_DECIMAL,
    CLAIMABLE_ZONE_AMOUNT_DECIMAL,
    TOTAL_ZONE_REDEMPTION_DECIMAL){
        this.BOND_NAME = BOND_NAME;
        this.BOND_TOKEN_ADDRESS = BOND_TOKEN_ADDRESS;
        this.ZONE_VALUE_DEPOSITED_DECIMAL = ZONE_VALUE_DEPOSITED_DECIMAL;
        this.CLAIMABLE_ZONE_AMOUNT_DECIMAL = CLAIMABLE_ZONE_AMOUNT_DECIMAL;
        this.TOTAL_ZONE_REDEMPTION_DECIMAL = TOTAL_ZONE_REDEMPTION_DECIMAL;
    }
}


class userProfile {
    
    constructor(){
    this.USER_ADDRESS;// = USER_ADDRESS;
    this.ZONE_BALANCE_DECIMAL; // = ZONE_BALANCE_DECIMAL;
    this.ZONE_BALANCE_CONTRACT; // = ZONE_BALANCE_CONTRACT;
    this.TWILIGHT_BALANCE_DECIMAL; // = TWILIGHT_BALANCE_DECIMAL;
    this.TWILIGHT_BALANCE_CONTRACT; // = TWILIGHT_BALANCE_CONTRACT;
    this.IS_ZONE_APPROVED; // = IS_ZONE_APPROVED;
    this.ZONE_APPROVAL_AMOUNT_DECIMAL; // = ZONE_APPROVAL_AMOUNT_DECIMAL;
    this.ZONE_APPROVAL_AMOUNT_CONTRACT; // = ZONE_APPROVAL_AMOUNT_CONTRACT;
    this.IS_TWILIGHT_APPROVED; // = IS_TWILIGHT_APPROVED;
    this.TWILIGHT_APPROVAL_AMOUNT_DECIMAL; // = TWILIGHT_APPROVAL_AMOUNT_DECIMAL;
    this.TWILIGHT_APPROVAL_AMOUNT_CONTRACT; // = TWILIGHT_APPROVAL_AMOUNT_CONTRACT;
    this.BOND_LIST; //= BOND_LIST; //Filled WIth an array of (BondNames => userBond)
    
    this.DEPOSITORY_ADDRESS; // = DEPOSITORY_ADDRESS;
    this.DEPOSITORY_ABI; // = DEPOSITORY_ABI;
    this.DIRSTRIBUTOR_ABI; // = DIRSTRIBUTOR_ABI;
    this.DIRSTRIBUTOR_ADDRESS; // = DIRSTRIBUTOR_ADDRESS;
    this.PROTOCOL_ABI; // = PROTOCOL_ABI;
    this.PROTOCOL_ADDRESS; // = PROTOCOL_ADDRESS;
    }
    
    async stake(_tokenAmountInDecimal){
        
        let sendAmount = ((_tokenAmountInDecial * ZONE_BALANCE_CONTRACT) / ZONE_BALANCE_DECIMAL);
        
        if(ZONE_APPROVAL_AMOUNT_CONTRACT >= sendAmount){
            let contract = new Web3.eth.Contract(this.DEPOSITORY_ABI, this.DEPOSITORY_ADDRESS);
            return (await contract.methods.stakeProtocol(sendAmount).send); //.then(function (result) {return result;});
        }
        
        return false; //Error Handling Here
    }
    
    async unStake(_tokenAmountInDecimal){
        
        let sendAmount = ((_tokenAmountInDecial * TWILIGHT_BALANCE_CONTRACT) / TWILIGHT_BALANCE_DECIMAL);
        
        if(ZONE_APPROVAL_AMOUNT_CONTRACT >= sendAmount){
            let contract = new Web3.eth.Contract(this.DEPOSITORY_ABI, this.DEPOSITORY_ADDRESS);
            return (await contract.methods.unstakeProtocol(sendAmount).send); //.then(function (result) {return result;});
        }
        
        return false; //Error Handling Here
    }
    
    
    //Needs to First Check Before Call That Token Allowance is >= _tokenAmount with => ((await retrieveQuery(["USER_DEPOSITORY_TOKEN_ALLOWANCE", USER_ADDRESS, "Token Address"])) / (await retrieveQuery(["TOKEN_DECIMALS", "Token Address"])))
    //Needs to conver to Contract format for _tokenAount, (tokenAmount *(await retrieveQuery(["TOKEN_DECIMALS", "Token Address"]))
    async bond(_bondName, _tokenAmountInContract){
        
        let contract = new Web3.eth.Contract(this.DEPOSITORY_ABI, this.DEPOSITORY_ADDRESS);
        return (await contract.methods.depositForBond(_bondName, _tokenAmountInContract).send); //.then(function (result) {return result;});
        
    }
    
    async claimBond(_bondName){
        
        if(BOND_LIST[_bondName].CLAIMABLE_ZONE_AMOUNT_DECIMAL >= 0){
            let contract = new Web3.eth.Contract(this.DEPOSITORY_ABI, this.DEPOSITORY_ADDRESS);
            return (await contract.methods.claimBond(_bondName).send); //.then(function (result) {return result;});
        }
        
        return false;  //ERROR HANDLING
    }

    async getUserBondDetails(_bondName){
        let bondData;
        for (let i = 0; i < this.BOND_LIST.length(); i++) {
            if(bondDataList[i].name == _bondName){
                bondData = bondDataList[i];
            }
        }
        let userTerms = new userBond;
       
        userTerms.BOND_NAME = _bondName;
        userTerms.BOND_TOKEN_ADDRESS = (await (new KCC.eth.Contract(this.DIRSTRIBUTOR_ABI, this.DIRSTRIBUTOR_ADDRESS)).methods.getBondByName(_bondName).call()).tokenAddress;
        
        let claimAmount = (await (new KCC.eth.Contract(this.DIRSTRIBUTOR_ABI, this.DIRSTRIBUTOR_ADDRESS)).methods.getBondByName(_bondName).call());
        userTerms.ZONE_VALUE_DEPOSITED_DECIMAL = (bondData.totalProtocolAmount - bondData.totalProtocolProfit) / (await (new KCC.eth.Contract(this.PROTOCOL_ABI, this.PROTOCOL_ADDRESS)).methods.decimals().call());
        userTerms.CLAIMABLE_ZONE_AMOUNT_DECIMAL = (await (new KCC.eth.Contract(this.DIRSTRIBUTOR_ABI, this.DIRSTRIBUTOR_ADDRESS)).methods.claimAmountForBond(_bondName, this.USER_ADDRESS).call()) / (await (new KCC.eth.Contract(this.PROTOCOL_ABI, this.PROTOCOL_ADDRESS)).methods.decimals().call());
        userTerms.TOTAL_ZONE_REDEMPTION_DECIMAL = (bondData.totalProtocolAmount - bondData.totalClaimedAmount) / (await (new KCC.eth.Contract(this.PROTOCOL_ABI, this.PROTOCOL_ADDRESS)).methods.decimals().call());
        return userTerms;
    }
    
}
