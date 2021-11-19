// test/Box.test.js
// Load dependencies
const { expect } = require('chai');

// Import utilities from Test Helpers
const { BN, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');

// Load compiled artifacts
const GamiumToken = artifacts.require('GamiumToken');

// Start test block
contract('GamiumToken', function ([ creator, other ]) {
    const tokenCapString = '50000000000000000000000000000';
    const tokenCap = new BN(tokenCapString);

    beforeEach(async function () {
    // Deploy a new GamiumToken contract for each test
        this.gamiumToken = await GamiumToken.new("Gamium", "GMM");
    });

    it('initializes total supply to 0', async function () {
        expect((await this.gamiumToken.totalSupply()).toString()).to.equal('0');
    });

    it('returns the maxixum total token cap', async function () {
        expect((await this.gamiumToken.cap()).toString()).to.equal(tokenCapString);
    });

    it('revert when mint non Minter role', async function () {
        await expectRevert(this.gamiumToken.mint(other, 23, { from: other }),"Caller is not the minter");
    });

    it('mint emits an events', async function () {
        await this.gamiumToken.setMinter(creator, { from: creator });
        const receipt = await this.gamiumToken.mint(other, 23, { from: creator });
        expectEvent(receipt, 'TokensMinted', {0: other, 1: new BN('23')});
    });

    it('cannot mint more than cap', async function () {
        await this.gamiumToken.setMinter(creator, { from: creator });
        await this.gamiumToken.mint(other, 23, { from: creator });
        await expectRevert(this.gamiumToken.mint(other, tokenCap, { from: creator }),"ERC20Capped: cap exceeded");
    });

    it('cannot mint when minter has changed', async function () {
        await this.gamiumToken.setMinter(creator, { from: creator });
        await this.gamiumToken.mint(other, 23, { from: creator });
        await this.gamiumToken.setMinter(other, { from: creator });
        await expectRevert(this.gamiumToken.mint(creator, 23, { from: creator }),"Caller is not the minter");
    });
});
