# Twilight-ZONE-Contracts

## Requirements:

* [Node v14](https://nodejs.org/download/release/latest-v14.x/)
* [Git](https://git-scm.com/downloads)

## Local Setup Steps:

* git clone https://github.com/TheTwilightZone/Twilight-ZONE-Contracts

* Install dependencies: npm install
  *Installs [Hardhat](https://hardhat.org/getting-started/) and [OpenZepplin dependencies](https://docs.openzeppelin.com/contracts/4.x/)

* Compile Solidity: npm run compile

## :construction_worker: How it all works:

![myImage](https://github.com/OlympusDAO/olympus-contracts/blob/main/docs/box-diagram.png)

|  Contract  |                   Address                  |        Notes        |
|:----------:|:------------------------------------------:|:-------------------:|
| ZONE token | 0x93cf46a13ab6a9f62a173f3ffba77ec184d0a74f | Main token contract |
| sZONE token| 0x0b6eafc6cc85f0eccde14e8ffca3c24fd91d92e4 | Staked ZONE token contract|
|            |                                            |                     |

## Allocator Guide
The following is a guide for interacting with the treasury as a reserve allocator.

A reserve allocator is a contract that deploys funds into external strategies, such as Aave, Curve, etc.


## Managing
The first step is withdraw funds from the treasury via the "manage" function. "Manage" allows an approved address to withdraw excess reserves from the treasury.

NOTE: This contract must have the "reserve manager" permission, and that withdrawn reserves decrease the treasury's ability to mint new OHM (since backing has been removed).

Pass in the token address and the amount to manage. The token will be sent to the contract calling the function.
```
function manage( address _token, uint _amount ) external;
```

Managing treasury assets should look something like this:
```
treasury.manage( DAI, amountToManage );
```

## Returning
The second step is to return funds after the strategy has been closed. We utilize the deposit function to do this. Deposit allows an approved contract to deposit reserve assets into the treasury, and mint OHM against them. In this case however, we will NOT mint any OHM. This will be explained shortly.

NOTE: The contract must have the "reserve depositor" permission, and that deposited reserves increase the treasury's ability to mint new OHM (since backing has been added).

Pass in the address sending the funds (most likely the allocator contract), the amount to deposit, and the address of the token. The final parameter, profit, dictates how much OHM to send. send_, the amount of OHM to send, equals the value of amount minus profit.

```
function deposit( address _from, uint _amount, address _token, uint _profit ) external returns ( uint send_ );
```
To ensure no OHM is minted, we first get the value of the asset, and pass that in as profit. Pass in the token address and amount to get the treasury value.

```
function valueOf( address _token, uint _amount ) public view returns ( uint value_ );
```
All together, returning funds should look something like this:

```
treasury.deposit( address(this), amountToReturn, DAI, treasury.valueOf( DAI, amountToReturn ) );
```

## Dapptools testing
Install [dapptools](https://github.com/dapphub/dapptools)

Pull the contract dependencies: `git submodule update --init --recursive`

Run `dapp test`
