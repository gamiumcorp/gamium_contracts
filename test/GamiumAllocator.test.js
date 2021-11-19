// test/Box.test.js
// Load dependencies
const { expect } = require('chai');

// Import utilities from Test Helpers
const { BN, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');

// Load compiled artifacts
const GamiumToken = artifacts.require('GamiumToken');
const GamiumAllocator = artifacts.require('GamiumAllocator');

// Start test block
contract('GamiumAllocator', function ([ creator, other ]) {
    const tokenCapString = '50000000000000000000000000000';
    const tokenCap = new BN(tokenCapString);

    const airdropTGE = '25000000000000000000000000';
    const seedTGE = '50000000000000000000000000';
    const privateTGE = '100000000000000000000000000';
    const publicTGE = '50000000000000000000000000';
    const advisorsTGE = '0';
    const stakingTGE = '0';
    const liquidityTGE = '1000000000000000000000000000';
    const treasuryTGE = '660000000000000000000000000';
    const marketingTGE = '380000000000000000000000000';
    const teamTGE = '0';
    const exchangesTGE = '1000000000000000000000000000';

    beforeEach(async function () {
    // Deploy a new GamiumToken contract for each test
        this.gamiumToken = await GamiumToken.new("Gamium", "GMM");
        this.gamiumAllocator = await GamiumAllocator.new(this.gamiumToken.address);
    });

    it('category releasable reverts when incorrect category', async function () {
        await expectRevert(this.gamiumAllocator.categoryReleasable("BadCategory"), "Category does not exist");
    });

    it('category releasable gives correct amount to be released', async function () {
        expect((await this.gamiumAllocator.categoryReleasable("Airdrop")).toString()).to.equal(airdropTGE);
        expect((await this.gamiumAllocator.categoryReleasable("Seed")).toString()).to.equal(seedTGE);
        expect((await this.gamiumAllocator.categoryReleasable("Private")).toString()).to.equal(privateTGE);
        expect((await this.gamiumAllocator.categoryReleasable("Public")).toString()).to.equal(publicTGE);
        expect((await this.gamiumAllocator.categoryReleasable("Advisors")).toString()).to.equal(advisorsTGE);
        expect((await this.gamiumAllocator.categoryReleasable("Staking")).toString()).to.equal(stakingTGE);
        expect((await this.gamiumAllocator.categoryReleasable("Liquidity")).toString()).to.equal(liquidityTGE);
        expect((await this.gamiumAllocator.categoryReleasable("Treasury")).toString()).to.equal(treasuryTGE);
        expect((await this.gamiumAllocator.categoryReleasable("Marketing")).toString()).to.equal(marketingTGE);
        expect((await this.gamiumAllocator.categoryReleasable("Team")).toString()).to.equal(teamTGE);
        expect((await this.gamiumAllocator.categoryReleasable("Exchanges")).toString()).to.equal(exchangesTGE);

        await this.gamiumToken.setMinter(this.gamiumAllocator.address);
        await this.gamiumAllocator.unlockLiquidity({ from: creator });

        expect((await this.gamiumAllocator.categoryReleasable("Airdrop")).toString()).to.equal(airdropTGE);
        expect((await this.gamiumAllocator.categoryReleasable("Seed")).toString()).to.equal(seedTGE);
        expect((await this.gamiumAllocator.categoryReleasable("Private")).toString()).to.equal(privateTGE);
        expect((await this.gamiumAllocator.categoryReleasable("Public")).toString()).to.equal(publicTGE);
        expect((await this.gamiumAllocator.categoryReleasable("Advisors")).toString()).to.equal(advisorsTGE);
        expect((await this.gamiumAllocator.categoryReleasable("Staking")).toString()).to.equal(stakingTGE);
        expect((await this.gamiumAllocator.categoryReleasable("Liquidity")).toString()).to.equal('0');
        expect((await this.gamiumAllocator.categoryReleasable("Treasury")).toString()).to.equal(treasuryTGE);
        expect((await this.gamiumAllocator.categoryReleasable("Marketing")).toString()).to.equal(marketingTGE);
        expect((await this.gamiumAllocator.categoryReleasable("Team")).toString()).to.equal(teamTGE);
        expect((await this.gamiumAllocator.categoryReleasable("Exchanges")).toString()).to.equal('0');
    });

    it('reverts when not owner unlocks liquidity', async function () {
        await expectRevert(this.gamiumAllocator.unlockLiquidity({ from: other }),"Ownable: caller is not the owner");
    });

    it('owner can unlock liquidity, balance is updated in GamiumToken contracts', async function () {
        await this.gamiumToken.setMinter(this.gamiumAllocator.address);
        expect((await this.gamiumToken.totalSupply()).toString()).to.equal('0');
        await this.gamiumAllocator.unlockLiquidity({ from: creator });
        expect((await this.gamiumToken.totalSupply()).toString()).to.equal('2000000000000000000000000000');
        expect((await this.gamiumAllocator.GMMReleased("Liquidity")).toString()).to.equal('1000000000000000000000000000');
        expect((await this.gamiumAllocator.GMMReleased("Exchanges")).toString()).to.equal('1000000000000000000000000000');
        expect((await this.gamiumAllocator.GMMReleased("Seed")).toString()).to.equal('0');
        expect((await this.gamiumAllocator.totalMinted()).toString()).to.equal('2000000000000000000000000000');
    });

    it('reverts when calling releaseTokens before TGE', async function () {
        await this.gamiumToken.setMinter(this.gamiumAllocator.address);
        await expectRevert(this.gamiumAllocator.releaseTokens({ from: other }),"TGE event did not start yet");
    });
});
