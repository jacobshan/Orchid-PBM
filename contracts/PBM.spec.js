const { assert, expect } = require('chai');

describe('PBM', async () => {
  const accounts = [];
  let SpotFactory;
  let PBMFactory;

  before(async () => {
    SpotFactory = await ethers.getContractFactory('Spot');
    PBMFactory = await ethers.getContractFactory('PBM');

    (await ethers.getSigners()).forEach((signer, index) => {
      accounts[index] = signer;
    });
  });

  async function init() {
    let spot = await SpotFactory.deploy();
    let pbm = await PBMFactory.deploy('');
    await pbm.initialise(spot.address, Math.round(new Date().getTime() / 1000 + 86400 * 30));
    return [spot, pbm];
  }

  describe('PBM and Spot Set up test', async () => {
    let spot;
    let pbm;

    before(async () => {
      let [_spot, _pbm] = await init();
      spot = _spot;
      pbm = _pbm;
    });

    it('Should deploy smart contract', async () => {
      assert(pbm.address != '');
      assert(spot.address != '');
    });

    it('Mint and Transfer Spot token to the PBM', async () => {
      var pbm_spot = await pbm.spotToken();
      assert.equal(spot.address, pbm_spot);
    });

    it('Mint tokens to PBM and check balance', async () => {
      await spot.mint(pbm.address, 10000);
      var balance = await spot.balanceOf(pbm.address);
      assert.equal(balance.toString(), '10000');
    });
  });

  describe('Minting test for PBM', () => {
    var spot = null;
    var pbm = null;

    before(async () => {
      let [_spot, _pbm] = await init();
      spot = _spot;
      pbm = _pbm;
    });

    it('Minting before creating the token type gives an error', async () => {
      await expect(pbm.mint(0, 1, accounts[0].address)).to.be.revertedWith('Invalid token id(s)');
    });

    it('Correctly adds the token type', async () => {
      currentDate = new Date();
      currentEpoch = Math.floor(currentDate / 1000);
      var targetEpoch = currentEpoch + 100000; // Expiry is set to 1 day 3.6 hours from current time
      await expect(pbm.createTokenType('StraitsX', 20, targetEpoch, '')).to
        .emit(pbm, 'newTokenTypeCreated')
        .withArgs(0, 'StraitsX20', 20, targetEpoch, accounts[0].address);
      var tokenDetails = await pbm.getTokenDetails(0);
      assert.equal(tokenDetails['0'], 'StraitsX20');
      assert.equal(tokenDetails['1'].toString(), '20');
      assert.equal(tokenDetails['2'].toString(), targetEpoch);
      assert.equal(tokenDetails['3'], accounts[0].address.toString());
    });

    it('Minting before funding the contract gives an error', async () => {
      const amount = 20;
      const targetEpoch = Math.round(new Date().getTime() / 1000 + 1000);
      const tokenId = (await pbm.createTokenType('StraitsX', amount, targetEpoch, '')).value;
      await expect(pbm.mint(tokenId, 1, accounts[0].address)).to.be.revertedWith('Insufficient spot tokens');
    });

    it('Mint 20 tokens to PBM and check balance', async () => {
      await spot.mint(pbm.address, 20);
      var balance = await spot.balanceOf(pbm.address);
      assert.equal(balance.toString(), '20');
    });

    it('Minting more than the funded amount should give an error', async () => {
      await expect(pbm.mint(0, 2, accounts[0].address)).to.be.revertedWith('Insufficient spot tokens');
    });

    it('Only the owner of the contract should be allowed to mint', async () => {
      await expect(pbm.connect(accounts[1]).mint(0, 2, accounts[1].address)).to.be.revertedWith('Ownable: caller is not the owner');
    });

    it('Add more funding and mint a PBM', async () => {
      await spot.mint(pbm.address, 20);
      var balance = await spot.balanceOf(pbm.address);
      assert.equal(balance.toString(), '40');

      // mint pbm
      await pbm.mint(0, 2, accounts[1].address);
      var NFTbalance = await pbm.balanceOf(accounts[1].address, 0);
      assert.equal(NFTbalance.toString(), '2');
      var NFTValueinPBM = await pbm.getSpotValueOfAllExistingTokens();
      assert.equal(NFTValueinPBM.toString(), '40');
    });

    it('Correct value of tokens is shown even during excess of spot funding', async () => {
      await spot.mint(pbm.address, 160);
      var balance = await spot.balanceOf(pbm.address);
      assert.equal(balance.toString(), '200');

      // mint pbms
      await pbm.mint(0, 3, accounts[2].address);
      var NFTbalance = await pbm.balanceOf(accounts[2].address, 0);
      assert.equal(NFTbalance.toString(), '3');
      var NFTValueinPBM = await pbm.getSpotValueOfAllExistingTokens();
      assert.equal(NFTValueinPBM.toString(), '100');
    });
  });

  // Unit tests to verify the Batch Mint of NFTs
  describe('Batch Mint of NFTs', () => {
    var spot = null;
    var pbm = null;

    before(async () => {
      let [_spot, _pbm] = await init();
      spot = _spot;
      pbm = _pbm;
    });

    it('Minting before creating the token type gives an error', async () => {
      await expect(pbm.mintBatch([0, 1], [1, 1], accounts[1].address)).to.be.revertedWith('Invalid token id(s)');
    });

    it('Minting before funding with partially invalid addresses gives an error', async () => {
      // creating a token type
      currentDate = new Date();
      currentEpoch = Math.floor(currentDate / 1000);
      var targetEpoch = currentEpoch + 100000; // Expiry is set to 1 day 3.6 hours from current time
      tokenId = await pbm.createTokenType('StraitsX', 20, targetEpoch, '');

      // trying to mint the contract
      await expect(pbm.mint([0, 1], [1, 1], accounts[0].address)).to.be.revertedWith('Invalid token id(s)');
    });

    it('Minting before funding the contract gives an error', async () => {
      // creating a token type
      currentDate = new Date();
      currentEpoch = Math.floor(currentDate / 1000);
      var targetEpoch = currentEpoch + 100000; // Expiry is set to 1 day 3.6 hours from current time
      tokenId = await pbm.createTokenType('Xfers', 10, targetEpoch, '');

      // trying to mint the contract
      await expect(pbm.mint([0, 1], [1, 1], accounts[0].address)).to.be.revertedWith('Insufficient spot tokens');
    });

    it('Mint 30 tokens to PBM and check balance', async () => {
      await spot.mint(pbm.address, 30);
      var balance = await spot.balanceOf(pbm.address);
      assert.equal(balance.toString(), '30');
    });

    it('Minting more than the funded amount should give an error', async () => {
      await expect(pbm.mint([0, 1], [1, 2], accounts[1].address)).to.be.revertedWith('Insufficient spot tokens');
    });

    it('Only the owner of the contract should be allowed to batch mint', async () => {
      await expect(pbm.connect(accounts[1]).mint([0, 1], [1, 1], accounts[1].address)).to.be.revertedWith('Ownable: caller is not the owner');
    });

    it('Add more funding and mint a PBM', async () => {
      await spot.mint(pbm.address, 20);
      var balance = await spot.balanceOf(pbm.address);
      assert.equal(balance.toString(), '50');

      // mint pbm
      await pbm.mintBatch([0, 1], [1, 3], accounts[1].address);
      var NFTbalanceToken0 = await pbm.balanceOf(accounts[1].address, 0);
      assert.equal(NFTbalanceToken0.toString(), '1');
      var NFTbalanceToken0 = await pbm.balanceOf(accounts[1].address, 1);
      assert.equal(NFTbalanceToken0.toString(), '3');
      var NFTValueinPBM = await pbm.getSpotValueOfAllExistingTokens();
      assert.equal(NFTValueinPBM.toString(), '50');
    });

    it('Correct value of tokens is shown even during excess of spot funding', async () => {
      await spot.mint(pbm.address, 150);
      var balance = await spot.balanceOf(pbm.address);
      assert.equal(balance.toString(), '200');

      // mint pbms
      await pbm.mintBatch([0, 1], [2, 2], accounts[1].address);
      var NFTbalanceToken0 = await pbm.balanceOf(accounts[1].address, 0);
      assert.equal(NFTbalanceToken0.toString(), '3');
      var NFTbalanceToken0 = await pbm.balanceOf(accounts[1].address, 1);
      assert.equal(NFTbalanceToken0.toString(), '5');
      var NFTValueinPBM = await pbm.getSpotValueOfAllExistingTokens();
      assert.equal(NFTValueinPBM.toString(), '110');
    });
  });

  describe('Expiry of tokens and contract', () => {
  });

  describe('Transfer of PBM NFTs', () => {
    var spot = null;
    var pbm = null;

    before(async () => {
      let [_spot, _pbm] = await init();
      spot = _spot;
      pbm = _pbm;
    });

    after(async () => {
      var NFTValueinPBM = await pbm.getSpotValueOfAllExistingTokens();
      assert.equal(NFTValueinPBM.toString(), '80');
    });

    it('setting up the contract for transfer testing', async () => {
      // minting spot tokens into wallet
      await spot.mint(pbm.address, 1000);
      // creating new token types
      currentDate = new Date();
      currentEpoch = Math.floor(currentDate / 1000);
      var targetEpoch = currentEpoch + 100000; // Expiry is set to 1 day 3.6 hours from current time
      await pbm.createTokenType('Xfers', 10, targetEpoch, '');
      await pbm.createTokenType('StraitsX', 20, targetEpoch, '');
      await pbm.createTokenType('Fazz', 10, targetEpoch, '');
      await pbm.mintBatch([0, 1, 2], [2, 2, 2], accounts[1].address);
    });

    it('Transfering tokens you don\'t own gives an error', async () => {
      await expect(pbm.safeTransferFrom(accounts[0].address, accounts[2].address, 0, 1, '0x')).to.be.revertedWith('ERC1155: insufficient balance for transfer')
      var balance = await pbm.balanceOf(accounts[2].address, 0);
      assert.equal(balance.toString(), '0');
    });

    it('Batch Transfering tokens you don\'t own gives an error', async () => {
      await expect(pbm.safeBatchTransferFrom(
        accounts[0].address,
        accounts[2].address,
        [0, 1],
        [1, 0],
        '0x',
      )).to.be.revertedWith('ERC1155: insufficient balance for transfer');
      const balance = await pbm.balanceOf(accounts[2].address, 0);
      assert.equal(balance.toString(), '0');
    });

    it('Transfering invalid token gives an error', async () => {
      await expect(pbm.connect(accounts[1]).safeTransferFrom(accounts[1].address, accounts[2].address, 3, 1, '0x')).to.be.revertedWith('Invalid token id(s)');
      const balance = await pbm.balanceOf(accounts[2].address, 0);
      assert.equal(balance.toString(), '0');
    });

    it('Batch transfering invalid tokens gives an error', async () => {
      await expect(pbm.connect(accounts[1]).safeBatchTransferFrom(
        accounts[1].address,
        accounts[2].address,
        [3, 2],
        [1, 0],
        '0x',
      )).to.be.revertedWith('Invalid token id(s)');
      const balance = await pbm.balanceOf(accounts[2].address, 0);
      assert.equal(balance.toString(), '0');
    });

    it('Valid Token Transfer', async () => {
      await pbm.connect(accounts[1]).safeTransferFrom(accounts[1].address, accounts[2].address, 0, 1, '0x');
      var account0Balance = await pbm.balanceOf(accounts[2].address, 0);
      assert.equal(account0Balance.toString(), '1');
      var account1Blanance = await pbm.balanceOf(accounts[1].address, 0);
      assert.equal(account1Blanance.toString(), '1');
    });

    it('Valid Batch Token Transfer', async () => {
      await pbm.connect(accounts[1]).safeBatchTransferFrom(
        accounts[1].address,
        accounts[3].address,
        [0, 2],
        [1, 2],
        '0x',
      );
      var account3Token0Balance = await pbm.balanceOf(accounts[3].address, 0);
      assert.equal(account3Token0Balance.toString(), '1');
      var account3Token2Balance = await pbm.balanceOf(accounts[3].address, 2);
      assert.equal(account3Token2Balance.toString(), '2');

      var account1Token0Balance = await pbm.balanceOf(accounts[1].address, 0);
      assert.equal(account1Token0Balance.toString(), '0');
      var account1Token2Balance = await pbm.balanceOf(accounts[1].address, 2);
      assert.equal(account1Token2Balance.toString(), '0');
    });
  });

  describe('Payment to whitelisted address through PBM NFTs', () => {
    var spot = null;
    var pbm = null;

    before(async () => {
      let [_spot, _pbm] = await init();
      spot = _spot;
      pbm = _pbm;
    });

    it('Setting up the contract for transfer testing', async () => {
      // minting spot tokens into wallet
      await spot.mint(pbm.address, 1000);
      // creating new token types
      currentDate = new Date();
      currentEpoch = Math.floor(currentDate / 1000);
      var targetEpoch = currentEpoch + 100000; // Expiry is set to 1 day 3.6 hours from current time
      await pbm.createTokenType('Xfers', 10, targetEpoch, '');
      await pbm.createTokenType('StraitsX', 20, targetEpoch, '');
      await pbm.createTokenType('Fazz', 10, targetEpoch, '');
      await pbm.mintBatch([0, 1, 2], [2, 2, 2], accounts[1].address);
    });

    it('Whitelisting merchant addresses', async () => {
      await pbm.seedMerchantList([accounts[4].address, accounts[5].address]);
      var merchant0 = await pbm.merchantList(accounts[4].address);
      var merchant1 = await pbm.merchantList(accounts[5].address);
      assert.equal(merchant0, true);
      assert.equal(merchant1, true);
    });

    it('Valid payment transaction', async () => {
      await pbm.connect(accounts[1]).safeTransferFrom(accounts[1].address, accounts[4].address, 1, 2, '0x');
      var NFTValueinPBM = await pbm.getSpotValueOfAllExistingTokens();
      assert.equal(NFTValueinPBM.toString(), '40');
      var account1Token1Balance = await pbm.balanceOf(accounts[1].address, 1);
      assert.equal(account1Token1Balance.toString(), '0');
      var balance = await spot.balanceOf(accounts[4].address);
      assert.equal(balance.toString(), '40');
    });

    it('Payment transaction using tokens you don\'t own', async () => {
      await expect(pbm.connect(accounts[1]).safeTransferFrom(accounts[1].address, accounts[5].address, 1, 2, '0x')).to.be.revertedWith('ERC1155: burn amount exceeds balance');
      const NFTValueinPBM = await pbm.getSpotValueOfAllExistingTokens();
      assert.equal(NFTValueinPBM.toString(), '40');
    });

    it('Valid batch payment transaction', async () => {
      await pbm.connect(accounts[1]).safeBatchTransferFrom(
        accounts[1].address,
        accounts[4].address,
        [0, 2],
        [1, 2],
        '0x',
      );
      var NFTValueinPBM = await pbm.getSpotValueOfAllExistingTokens();
      assert.equal(NFTValueinPBM.toString(), '10');
      var account1Token0Balance = await pbm.balanceOf(accounts[1].address, 0);
      assert.equal(account1Token0Balance.toString(), '1');
      var account1Token2Balance = await pbm.balanceOf(accounts[1].address, 2);
      assert.equal(account1Token2Balance.toString(), '0');
      var balance = await spot.balanceOf(accounts[4].address);
      assert.equal(balance.toString(), '70');
    });

    it('Batch payment transaction using tokens you don\'t own', async () => {
      await expect(pbm.connect(accounts[1]).safeBatchTransferFrom(
        accounts[1].address,
        accounts[5].address,
        [0, 1],
        [1, 2],
        '0x',
      )).to.be.reverted;
      const account1Token0Balance = await pbm.balanceOf(accounts[1].address, 0);
      assert.equal(account1Token0Balance.toString(), '1');
      const NFTValueinPBM = await pbm.getSpotValueOfAllExistingTokens();
      assert.equal(NFTValueinPBM.toString(), '10');
    });
  });

  contract('Withdraw funds NFT', () => {
  });

  contract('Pausability of the smartcontract', () => {
  });
});
