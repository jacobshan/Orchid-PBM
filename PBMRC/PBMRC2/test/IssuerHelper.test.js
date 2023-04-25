const { expect } = require("chai");

describe("IssuerHelper", function () {
  let IssuerHelper, issuerHelper, PBM, pbm, ERC20, erc20, owner, wallet1, wallet2, whitelister1, whitelister2;

  beforeEach(async () => {
    // Deploy PBM mock
    PBM = await ethers.getContractFactory("PBM");
    pbm = await PBM.deploy();
    await pbm.deployed();

    // Deploy IssuerHelper
    IssuerHelper = await ethers.getContractFactory("IssuerHelper");
    issuerHelper = await IssuerHelper.deploy(pbm.address);
    await issuerHelper.deployed();

    // Deploy ERC20 mock
    ERC20 = await ethers.getContractFactory("ERC20");
    erc20 = await ERC20.deploy("TestToken", "TEST");
    await erc20.deployed();

    [owner, wallet1, wallet2, whitelister1, whitelister2] = await ethers.getSigners();
  });

  describe("Whitelisting wallets", function () {
    it("Should add a wallet to the whitelist", async function () {
      await issuerHelper.connect(owner).addWhitelistedWallet(wallet1.address);
      expect(await issuerHelper.whitelistedWallets(wallet1.address)).to.equal(true);
    });

    it("Should remove a wallet from the whitelist", async function () {
      await issuerHelper.connect(owner).addWhitelistedWallet(wallet1.address);
      await issuerHelper.connect(owner).removeWhitelistedWallet(wallet1.address);
      expect(await issuerHelper.whitelistedWallets(wallet1.address)).to.equal(false);
    });
  });

  describe("Managing allowed whitelisters", function () {
    it("Should add a whitelister", async function () {
      await issuerHelper.connect(owner).addWhitelister(whitelister1.address);
      expect(await issuerHelper.allowedWhitelisters(whitelister1.address)).to.equal(true);
    });

    it("Should remove a whitelister", async function () {
      await issuerHelper.connect(owner).addWhitelister(whitelister1.address);
      await issuerHelper.connect(owner).removeWhitelister(whitelister1.address);
      expect(await issuerHelper.allowedWhitelisters(whitelister1.address)).to.equal(false);
    });
  });

  describe("processLoadAndPay", function () {
    beforeEach(async () => {
      // Mint tokens to wallet1
      await erc20.mint(wallet1.address, ethers.utils.parseEther("1000"));

      // Approve IssuerHelper to spend wallet1's tokens
      await erc20.connect(wallet1).approve(issuerHelper.address, ethers.utils.parseEther("1000"));

      // Add wallet1 to the whitelist
      await issuerHelper.connect(owner).addWhitelistedWallet(wallet1.address);

      // Add whitelister1 as allowed whitelister
      await issuerHelper.connect(owner).addWhitelister(whitelister1.address);
    });


    it("Should call processLoadAndPay and transfer tokens", async function () {
        const amount = ethers.utils.parseEther("10");
  
        // Get initial balances
        const initialIssuerHelperBalance = await erc20.balanceOf(issuerHelper.address);
        const initialWallet1Balance = await erc20.balanceOf(wallet1.address);
  
        // Call processLoadAndPay
        await issuerHelper.connect(whitelister1).processLoadAndPay(erc20.address, wallet1.address, amount);
  
        // Get final balances
        const finalIssuerHelperBalance = await erc20.balanceOf(issuerHelper.address);
        const finalWallet1Balance = await erc20.balanceOf(wallet1.address);
  
        // Check if token transfer was successful
        expect(initialIssuerHelperBalance.add(amount)).to.equal(finalIssuerHelperBalance);
        expect(initialWallet1Balance.sub(amount)).to.equal(finalWallet1Balance);
      });
  
      it("Should fail if the wallet is not whitelisted", async function () {
        const amount = ethers.utils.parseEther("10");
  
        // Remove wallet1 from the whitelist
        await issuerHelper.connect(owner).removeWhitelistedWallet(wallet1.address);
  
        // Try calling processLoadAndPay
        await expect(
          issuerHelper.connect(whitelister1).processLoadAndPay(erc20.address, wallet1.address, amount)
        ).to.be.revertedWith("Wallet is not whitelisted");
      });
  
      it("Should fail if the caller is not an allowed whitelister", async function () {
        const amount = ethers.utils.parseEther("10");
  
        // Remove whitelister1 as an allowed whitelister
        await issuerHelper.connect(owner).removeWhitelister(whitelister1.address);
  
        // Try calling processLoadAndPay
        await expect(
          issuerHelper.connect(whitelister1).processLoadAndPay(erc20.address, wallet1.address, amount)
        ).to.be.revertedWith("Caller is not an allowed whitelister");
      });
    });
  });
  
