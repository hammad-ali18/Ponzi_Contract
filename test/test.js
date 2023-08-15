const { BigNumber } = require('bignumber.js')
const { expect } = require("chai");
const { reverse } = require("dns");
const { poll} = require("ethers/lib/utils");
const { waffle,ethers } = require("hardhat");
const { userInfo } = require("os");
const { register } = require("ts-node");
const provider = waffle.provider;

// const { describe, it } = require('mocha'); // for Mocha

const Web3 = require('web3');
// const web3 = new Web3();
const hre = require("hardhat");
const namehash = require('eth-ens-namehash');
const { BaseRegistrar, BaseRegistrarImplementation, PriceOracle, DummyOracle, AggregatorInterface, StablePriceOracle,NameWrapper } = require("@ensdomains/ens-contracts");
// const exp = require("constants");
const tld = "test";
// const ethers = hre.ethers;
// const utils = ethers.utils;
const labelhash = (label) => utils.keccak256(utils.toUtf8Bytes(label))
const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";
const ZERO_HASH = "0x0000000000000000000000000000000000000000000000000000000000000000";
const baseNode ="0x84ef65b3506f5b54a01171c1a50a4b6f269e1a8112d7764e49a36185ebeb3d07";

const minCommitmentAge=60
const maxCommitmentAge=3600


// const ethers = require('ethers');

const name  = 'hammad.eth';

describe('Testing ENS Contracts', () =>{

    const [owner, accountOne,accountTwo,accountThree,accountFour] = provider.getWallets();


    before( async () =>{
        Ponzi = await ethers.getContractFactory("PonziContract");
        ponzi = await Ponzi.deploy();

        Attack = await ethers.getContractFactory("AttackerContract");
        attack = await Attack.deploy(ponzi.address);


    })

    it('Funds Ponzi and Meet All Pre requirements for Attack', async () =>{
        // console.log(Web3.utils)
        // const ethValue = await Web3.utils.toWei("10")
        await ponzi.setDeadline(1692102820+86400);
        await ponzi.addNewAffilliate(accountOne.address);

        await owner.sendTransaction({to:ponzi.address,value:"10000000000000000000"});

        const balance = await provider.getBalance(ponzi.address);
        await expect(balance).equal("10000000000000000000");

})

it('Attack the contract and drain all the Eth with no Cost', async () =>{
    // const ethValue = await Web3.utils.toWei("10")
    const balance2Drain = await provider.getBalance(ponzi.address);
    const balanceBefore = await provider.getBalance(attack.address);

    await attack.connect(accountFour).stealEtherandOwnerShip({value:"10000000000000000000"});
    const balanceAfter = await provider.getBalance(attack.address);
    // console.log("balance after", balanceAfter);

    await expect(balanceAfter.sub("10000000000000000000")).equal(balance2Drain);




})

})