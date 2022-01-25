const fs = require('fs');
const Web3 = require('web3');
const KCC = new Web3("https://rpc-mainnet.kcc.network");


//This Can Derive All Other ADDYS
const distributorContractAddy = "0xcB110fc3d8CaeBC81eCa54D77E29E97fbC7497f9";

test();
async function test() {
    console.log('ZONE Token Address: ' + await retrieveQuery(["PROTOCOL_TOKEN_CONTRACT_ADDRESS"]));
    console.log('TWLT Token Address: ' + await retrieveQuery(["STAKED_TOKEN_CONTRACT_ADDRESS"]));
    console.log('Distributor Address: ' + await retrieveQuery(["DISTRIBUTOR_CONTRACT_ADDRESS"]));
    console.log('Calculator Address: ' + await retrieveQuery(["CALCULATOR_CONTRACT_ADDRESS"]));
    console.log('Depository Address: ' + await retrieveQuery(["DEPOSITORY_CONTRACT_ADDRESS"]));
    console.log('ZONE in USD: ' + await retrieveQuery(["PROTOCOL_PRICE_USD"]));
    console.log('ZONE in WKCS: ' + await retrieveQuery(["PROTOCOL_PRICE_WKCS"]));
    console.log('WKCS in USD: ' + await retrieveQuery(["KCS_PRICE_USD"]));
    console.log('ZONE Decimals: ' + await retrieveQuery(["PROTOCOL_DECIMALS"]));
    console.log('TWLT Decimals: ' + await retrieveQuery(["STAKED_DECIMALS"]));
    console.log('Next ZONE Rebase Block: ' + await retrieveQuery(["PROTOCOL_NEXT_REBASE"]));
    console.log('Rebase Block Increment: ' + await retrieveQuery(["PROTOCOL_REBASE_BLOCK_AMOUNT"]));
    console.log('ZONE Rebase Amount Per One ZONE Staked: ' + await retrieveQuery(["PROTOCOL_REBASE_AMOUNT"]));
    console.log('Current KCC Block: ' + await retrieveQuery(["CURRENT_BLOCK"]));
    console.log('Seconds Per KCC Block: ' + await retrieveQuery(["SECONDS_PER_BLOCK"]));
    console.log('ZONE Per One TWLT: ' + await retrieveQuery(["STAKED_TO_PROTOCOL"]));
    console.log('TWLT Per One ZONE: ' + await retrieveQuery(["PROTOCOL_TO_STAKED"]));
    console.log('Bond List: ' + await retrieveQuery(["LIST_BONDS"]));
    console.log("All User's Bond Terms: " + await retrieveQuery(["USER_BOND_TERMS", "0xA45464bDDf0956D92D3C9d2DDDe7B8CB8b22ebFD"]));
    console.log("Get Bond By Name: " + await retrieveQuery(["GET_BOND", "WKCS OHM LP BOND"]));
    console.log("ZONE Profit Per ZONE Invested In Bond: " + await retrieveQuery(["BOND_PROFIT_PER_PROTOCOL", "WKCS OHM LP BOND"]));
    console.log("ZONE Token Supply: " + await retrieveQuery(["PROTOCOL_TOKEN_SUPPLY"]));
    console.log("TWLT Token Supply: " + await retrieveQuery(["STAKED_TOKEN_SUPPLY"]));
    console.log("How Much ZONE is Staked (Not In Total Supply): " + await retrieveQuery(["PROTOCOL_STAKED_AMOUNT"]));
    console.log("Users ZONE Balance: " + await retrieveQuery(["USER_PROTOCOL_TOKEN_BALANCE", "0xA45464bDDf0956D92D3C9d2DDDe7B8CB8b22ebFD"]));
    console.log("Users TWLT Balance: " + await retrieveQuery(["USER_STAKED_TOKEN_BALANCE", "0xA45464bDDf0956D92D3C9d2DDDe7B8CB8b22ebFD"]));
    console.log("Stake APY (1 Year) In Decimal: " + await retrieveQuery(["STAKE_APY_1YEAR"]));
    console.log("Stake APY (5 Days) In Decimal: " + await retrieveQuery(["STAKE_APY_5DAYS"]));
    console.log("User Profile: " + await retrieveQuery(["USER_PROFILE", "0xA45464bDDf0956D92D3C9d2DDDe7B8CB8b22ebFD"]));
    //console.log('ZONE Amount Earned Per One ZONE STAKED: ' + await retrieveQuery(["SECONDS_PER_BLOCK"]));
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

        //Helper Cases
        case "PROTOCOL_TOKEN_CONTRACT_ADDRESS":
            return (await getContractInstance("CALCULATOR_CONTRACT")).methods.protocolToken().call();
        case "STAKED_TOKEN_CONTRACT_ADDRESS":
            return (await getContractInstance("CALCULATOR_CONTRACT")).methods.stakedProtocolToken().call();
        case "DISTRIBUTOR_CONTRACT_ADDRESS":
            return (distributorContractAddy);
        case "CALCULATOR_CONTRACT_ADDRESS":
            return (await getContractInstance("DISTRIBUTOR_CONTRACT")).methods.protocolCalculatorOracle().call();
        case "DEPOSITORY_CONTRACT_ADDRESS":
            return (await getContractInstance("DISTRIBUTOR_CONTRACT")).methods.assetDepository().call();
        case "TOKEN_DECIMALS":
            return (await (new KCC.eth.Contract(await retrieveABI('PROTOCOL_TOKEN_CONTRACT'), query[1])).methods.decimals().call());
        case "TOKEN_SUPPLY":
            return (await (new KCC.eth.Contract(await retrieveABI('PROTOCOL_TOKEN_CONTRACT'), query[1])).methods.totalSupply().call());
        case "SECONDS_PER_BLOCK":
            return 3;
        case "CURRENT_BLOCK":
            return (await (await getContractInstance("DISTRIBUTOR_CONTRACT")).methods.currentBlock().call());
        case "USER_TOKEN_BALANCE":
            return (await (new KCC.eth.Contract(await retrieveABI('PROTOCOL_TOKEN_CONTRACT'), query[1])).methods.balanceOf(query[2]).call());
        //End Helper Cases


        //Price Cases
        case "PROTOCOL_PRICE_USD":
            let protocolInKCS = (await retrieveQuery(['PROTOCOL_PRICE_WKCS']));
            let wkcsDecimals = 10 ** 18;
            let kcsPriceUSD = await retrieveQuery(['KCS_PRICE_USD']);
            return (( protocolInKCS * kcsPriceUSD) / wkcsDecimals);
        case "PROTOCOL_PRICE_WKCS":
            return (await getContractInstance("CALCULATOR_CONTRACT")).methods.protocolTokenPrice().call();
        case "KCS_PRICE_USD":
            let routerABI = [{ "inputs": [{ "internalType": "uint256", "name": "amountIn", "type": "uint256" }, { "internalType": "address[]", "name": "path", "type": "address[]" }], "name": "getAmountsOut", "outputs": [{ "internalType": "uint256[]", "name": "amounts", "type": "uint256[]" }], "stateMutability": "view", "type": "function" }];
            let kuswapRouter = new KCC.eth.Contract(routerABI, "0xa58350d6dee8441aa42754346860e3545cc83cda");
            let response = await kuswapRouter.methods.getAmountsOut(1000000000, ["0x4446fc4eb47f2f6586f9faab68b3498f86c07521", "0x980a5afef3d17ad98635f6c5aebcbaeded3c3430"]).call();
            return Number((response[1] / (10 ** 9)));
        //End Price Cases


        case "PROTOCOL_DECIMALS":
            return (await retrieveQuery(['TOKEN_DECIMALS', await retrieveQuery(['PROTOCOL_TOKEN_CONTRACT_ADDRESS'])]));
        case "STAKED_DECIMALS":
            return (await retrieveQuery(['TOKEN_DECIMALS', await retrieveQuery(['STAKED_TOKEN_CONTRACT_ADDRESS'])]));
        case "PROTOCOL_NEXT_REBASE":
            return (await (await getContractInstance("DISTRIBUTOR_CONTRACT")).methods.stakingReward().call()).nextRewardBlock;
        case "PROTOCOL_REBASE_AMOUNT":
            return (await (await getContractInstance("DISTRIBUTOR_CONTRACT")).methods.stakingReward().call()).protocolRewardAmount;
        case "STAKED_TO_PROTOCOL":
            let oneStaked = (10 ** await retrieveQuery(['STAKED_DECIMALS'])).toString();
            return (await (await getContractInstance("STAKED_CONTRACT")).methods.reserveToProtocol(oneStaked).call());
        case "PROTOCOL_TO_STAKED":
            let oneProtocol = (10 ** await retrieveQuery(['PROTOCOL_DECIMALS'])).toString()
            return (await (await getContractInstance("STAKED_CONTRACT")).methods.reserveToProtocol(oneProtocol).call());
        case "LIST_BONDS":
            return (await (await getContractInstance("DISTRIBUTOR_CONTRACT")).methods.listBonds().call());
        case "USER_BOND_TERMS":
            return (await (await getContractInstance("DISTRIBUTOR_CONTRACT")).methods.listUserBonds(query[1]).call());
        case "GET_BOND":
            return (await (await getContractInstance("DISTRIBUTOR_CONTRACT")).methods.getBondByName(query[1]).call());
        case "BOND_PROFIT_PER_PROTOCOL":
            let pullBond = await retrieveQuery(['GET_BOND', query[1]]);
            let oneProtocol2 = (10 ** await retrieveQuery(['PROTOCOL_DECIMALS'])).toString();
            return ( Number(oneProtocol2) * (pullBond.multiplier / 1000));
        case "STAKED_TOKEN_SUPPLY":
            return (await retrieveQuery(["TOKEN_SUPPLY", await retrieveQuery(["STAKED_TOKEN_CONTRACT_ADDRESS"])]));
        case "PROTOCOL_TOKEN_SUPPLY":
            return (await retrieveQuery(["TOKEN_SUPPLY", await retrieveQuery(["PROTOCOL_TOKEN_CONTRACT_ADDRESS"])]));
        case "PROTOCOL_STAKED_AMOUNT":
            return (await (await getContractInstance('STAKED_CONTRACT')).methods.protocolReservoir().call());
        case "USER_PROTOCOL_TOKEN_BALANCE":
            return (await retrieveQuery(['USER_TOKEN_BALANCE', await retrieveQuery(["PROTOCOL_TOKEN_CONTRACT_ADDRESS"]), query[1]]));
        case "USER_STAKED_TOKEN_BALANCE":
            return (await retrieveQuery(['USER_TOKEN_BALANCE', await retrieveQuery(["STAKED_TOKEN_CONTRACT_ADDRESS"]), query[1]]));
        case "STAKE_APY_1YEAR":
            let baseToken = (10 ** await retrieveQuery(["PROTOCOL_DECIMALS"])).toString();
            let rebaseProfit = await retrieveQuery(["PROTOCOL_REBASE_AMOUNT"])
            let compoundTimeInSecconds = (await retrieveQuery(["PROTOCOL_REBASE_BLOCK_AMOUNT"]) * await retrieveQuery(["SECONDS_PER_BLOCK"]));
            let percentage = (rebaseProfit / Number(baseToken)).toString();
            let periodsPerYear = ((31536000 / compoundTimeInSecconds).toFixed(2)).toString();
            return ((Number(baseToken) * (Math.pow((1 + (Number(percentage) / Number(periodsPerYear))), (Number(periodsPerYear) * 1)))).toFixed(2)).toString();
        case "STAKE_APY_5DAYS":
            let baseToken2 = (10 ** await retrieveQuery(["PROTOCOL_DECIMALS"])).toString();
            let rebaseProfit2 = await retrieveQuery(["PROTOCOL_REBASE_AMOUNT"])
            let compoundTimeInSecconds2 = (await retrieveQuery(["PROTOCOL_REBASE_BLOCK_AMOUNT"]) * await retrieveQuery(["SECONDS_PER_BLOCK"]));
            let percentage2 = (rebaseProfit2 / Number(baseToken2)).toString();
            let periodsPer5Days = ((432000 / compoundTimeInSecconds2).toFixed(2)).toString();
            return ((Number(baseToken2) * (Math.pow((1 + (Number(percentage2) / Number(periodsPer5Days))), (Number(periodsPer5Days) * 1)))).toFixed(2)).toString();
        case "PROTOCOL_REBASE_BLOCK_AMOUNT":
            return (await (await getContractInstance("DISTRIBUTOR_CONTRACT")).methods.stakingReward().call()).everyBlockAmount;
        case "USER_PROFILE":
                let profile = new userProfile;
                profile.USER_ADDRESS = query[1];
                profile.ZONE_BALANCE_CONTRACT = (await retrieveQuery(["USER_PROTOCOL_TOKEN_BALANCE", profile.USER_ADDRESS]));
                profile.ZONE_BALANCE_DECIMAL = (profile.ZONE_BALANCE_CONTRACT / Number((10 ** (await retrieveQuery(["PROTOCOL_DECIMALS"])).toString()))).toString();
                profile.TWILIGHT_BALANCE_CONTRACT = (await retrieveQuery(["USER_STAKED_TOKEN_BALANCE", profile.USER_ADDRESS]));
                profile.TWILIGHT_BALANCE_DECIMAL = (profile.TWILIGHT_BALANCE_CONTRACT / Number((10 ** (await retrieveQuery(["STAKED_DECIMALS"])).toString()))).toString();
                profile.ZONE_APPROVAL_AMOUNT_CONTRACT = await (await getContractInstance("PROTOCOL_CONTRACT")).methods.allowance(profile.USER_ADDRESS, await retrieveQuery(["DEPOSITORY_CONTRACT_ADDRESS"])).call();
                profile.TWILIGHT_APPROVAL_AMOUNT_CONTRACT = await (await getContractInstance("STAKED_CONTRACT")).methods.allowance(profile.USER_ADDRESS, await retrieveQuery(["DEPOSITORY_CONTRACT_ADDRESS"])).call();
                profile.ZONE_APPROVAL_AMOUNT_DECIMAL = (profile.ZONE_APPROVAL_AMOUNT_CONTRACT / Number((10 ** (await retrieveQuery(["PROTOCOL_DECIMALS"])).toString()))).toString();
                profile.TWILIGHT_APPROVAL_AMOUNT_DECIMAL = (profile.TWILIGHT_APPROVAL_AMOUNT_CONTRACT / Number((10 ** (await retrieveQuery(["STAKED_DECIMALS"])).toString()))).toString()

                if(profile.ZONE_APPROVAL_AMOUNT_CONTRACT > 0){profile.IS_ZONE_APPROVED = true}else{profile.IS_ZONE_APPROVED = false}
                if(profile.TWILIGHT_APPROVAL_AMOUNT_CONTRACT > 0){profile.IS_TWILIGHT_APPROVED = true}else{profile.IS_TWILIGHT_APPROVED = false}
    
                profile.DEPOSITORY_ADDRESS = await retrieveQuery(['DEPOSITORY_CONTRACT_ADDRESS']);
                profile.DEPOSITORY_ABI = await retrieveABI('DEPOSITORY_CONTRACT');
                profile.DISTRIBUTOR_ADDRESS = await retrieveQuery(['DISTRIBUTOR_CONTRACT_ADDRESS']);
                profile.DISTRIBUTOR_ABI = await retrieveABI('DISTRIBUTOR_CONTRACT');
                profile.PROTOCOL_ABI = await retrieveABI('PROTOCOL_CONTRACT');
                profile.PROTOCOL_ADDRESS =  await retrieveQuery('PROTOCOL_CONTRACT_ADDRESS');
    
                profile.BOND_LIST = (await (await getContractInstance("DISTRIBUTOR_CONTRACT")).methods.listUserBonds(profile.USER_ADDRESS).call());

            return profile;


            case "APPROVE_STAKE":
                let pro = new userProfile;
                pro.USER_ADDRESS = query[1];
                pro.ZONE_BALANCE_CONTRACT = (await retrieveQuery(["USER_TOKEN_BALANCE", await retrieveQuery(['PROTOCOL_TOKEN_CONTRACT_ADDRESS']), pro.USER_ADDRESS]));
                pro.ZONE_BALANCE_DECIMAL = ((await retrieveQuery(["PROTOCOL_DECIMALS"])) ** pro.ZONE_BALANCE_CONTRACT);
                let result = await pro.stake(query[2]);
                console.log(result)
                return null
    
        }
    
    }
    
    
    
    /* eslint-disable no-unused-expressions */
    class userBond{
        constructor(){
            this.BOND_NAME; // = BOND_NAME;
            this.BOND_TOKEN_ADDRESS; // = BOND_TOKEN_ADDRESS;
            this.ZONE_VALUE_DEPOSITED_DECIMAL; // = ZONE_VALUE_DEPOSITED_DECIMAL;
            this.CLAIMABLE_ZONE_AMOUNT_DECIMAL; // = CLAIMABLE_ZONE_AMOUNT_DECIMAL;
            this.TOTAL_ZONE_REDEMPTION_DECIMAL; // = TOTAL_ZONE_REDEMPTION_DECIMAL;
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
    
        async approve(_tokenContractAddress, _tokenAmount){
            let contract = new web3userctx.eth.Contract(this.PROTOCOL_ABI, _tokenContractAddress);
            retrun(await contract.methods.approve( this.DEPOSITORY_ADDRESS, _tokenAmount).send);
        }
    
        async stake(_tokenAmountInDecimal){
    
            let sendAmount = ((_tokenAmountInDecimal * this.ZONE_BALANCE_CONTRACT) / this.ZONE_BALANCE_DECIMAL);
            debugger;
            if(this.ZONE_APPROVAL_AMOUNT_CONTRACT >= sendAmount){
                let contract = new web3userctx.eth.Contract(this.DEPOSITORY_ABI, this.DEPOSITORY_ADDRESS);
                return (await contract.methods.stakeProtocol(sendAmount).send); //.then(function (result) {return result;});
            }
            console.log(_tokenAmountInDecimal)
    
            return false; //Error Handling Here
        }
    
        async unStake(_tokenAmountInDecimal){
    
            let sendAmount = ((_tokenAmountInDecimal * this.TWILIGHT_BALANCE_CONTRACT) / this.TWILIGHT_BALANCE_DECIMAL);
    
            if(this.ZONE_APPROVAL_AMOUNT_CONTRACT >= sendAmount){
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
    
            if(this.BOND_LIST[_bondName].CLAIMABLE_ZONE_AMOUNT_DECIMAL >= 0){
                let contract = new Web3.eth.Contract(this.DEPOSITORY_ABI, this.DEPOSITORY_ADDRESS);
                return (await contract.methods.claimBond(_bondName).send); //.then(function (result) {return result;});
            }
    
            return false;  //ERROR HANDLING
        }
    
        async getUserBondDetails(_bondName){
            let bondData;
            for (let i = 0; i < this.BOND_LIST.length(); i++) {
                if(this.BOND_LIST[i].name == _bondName){
                    bondData = this.BOND_LIST[i];
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

async function getContractInstance(query){
    switch (query) {

        case "PROTOCOL_CONTRACT":
            return (new KCC.eth.Contract(await retrieveABI('PROTOCOL_TOKEN_CONTRACT'), await retrieveQuery(['PROTOCOL_TOKEN_CONTRACT_ADDRESS'])));
        case "STAKED_CONTRACT":
            return (new KCC.eth.Contract(await retrieveABI('STAKED_TOKEN_CONTRACT'), await retrieveQuery(['STAKED_TOKEN_CONTRACT_ADDRESS'])));
        case "DISTRIBUTOR_CONTRACT":
            return await (new KCC.eth.Contract(await retrieveABI('DISTRIBUTOR_CONTRACT'), await retrieveQuery(['DISTRIBUTOR_CONTRACT_ADDRESS'])));
        case "CALCULATOR_CONTRACT":
            return await (new KCC.eth.Contract(await retrieveABI('CALCULATOR_CONTRACT'), await retrieveQuery(['CALCULATOR_CONTRACT_ADDRESS'])));
        case "DEPOSITORY_CONTRACT":
            return JSON.parse(fs.readFileSync('./contractABI/Depositor.json'));

    }
}