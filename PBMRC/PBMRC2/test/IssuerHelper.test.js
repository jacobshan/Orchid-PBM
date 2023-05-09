const { expect } = require("chai");
const { ethers } = require("hardhat");
// const { signMetaTxRequest } = require("../../src/signer");

describe("IssuerHelper", function () {
  let IssuerHelper;
  let issuerHelper;
  let PBMRC2;
  let pbmrc2;
  let owner, whitelister, wallet, other;
  let erc20Token;
  let minimalForwarder;
  
  beforeEach(async function () {
    // Deploy a mock ERC20 token
    const ERC20 = await ethers.getContractFactory("Spot");
    erc20Token = await ERC20.deploy();
    await erc20Token.deployed();

    // Get the signers
    [owner, whitelister, wallet, other] = await ethers.getSigners();

    // Deploy the PBMRC2 contract
    PBMRC2 = await ethers.getContractFactory("PBMRC2");
    pbmrc2 = await PBMRC2.deploy();
    await pbmrc2.deployed();

    // Deploy the MinimalForwarder contract
    const MinimalForwarder = await ethers.getContractFactory("MinimalForwarder");
    minimalForwarder = await MinimalForwarder.deploy();
    await minimalForwarder.deployed();

    // Deploy the IssuerHelper contract
    IssuerHelper = await ethers.getContractFactory("IssuerHelper");
    issuerHelper = await IssuerHelper.deploy(pbmrc2.address, minimalForwarder.address);
    await issuerHelper.deployed();
    await issuerHelper.addWhitelister(owner.address);

    // Add the whitelister and wallet as allowed entities
    await issuerHelper.addWhitelister(whitelister.address);
    await issuerHelper.addWhitelistedWallet(wallet.address);

    // Give the wallet some tokens
    await erc20Token.mint(wallet.address, ethers.utils.parseUnits("1000", 18));
  });

  describe("processLoadAndSafeTransfer", function () {
    it("should transfer tokens from wallet to IssuerHelper and call loadAndSafeTransfer on PBMRC2", async function () {
      // Grant allowance to the issuerHelper contract by the wallet
      await erc20Token.connect(wallet).approve(issuerHelper.address, ethers.utils.parseUnits("100", 18));

      // Check the initial balances
      const initialIssuerHelperBalance = await erc20Token.balanceOf(issuerHelper.address);
      const initialWalletBalance = await erc20Token.balanceOf(wallet.address);

       // Perform the processLoadAndSafeTransfer function call
      await issuerHelper.connect(wallet).processLoadAndSafeTransfer(erc20Token.address, wallet.address, ethers.utils.parseUnits("50", 18));

      // Check the final balances
      const finalIssuerHelperBalance = await erc20Token.balanceOf(issuerHelper.address);
      const finalWalletBalance = await erc20Token.balanceOf(wallet.address);
      expect(finalIssuerHelperBalance.sub(initialIssuerHelperBalance)).to.equal(ethers.utils.parseUnits("50", 18));
      expect(initialWalletBalance.sub(finalWalletBalance)).to.equal(ethers.utils.parseUnits("50", 18));
    });

    it("should fail if caller is not an allowed whitelister", async function () {
      await expect(
        issuerHelper.connect(other).addWhitelistedWallet(wallet.address)
      ).to.be.revertedWith("Caller is not an allowed whitelister");
    });
    
    it("should fail if wallet is not whitelisted", async function () {
      await issuerHelper.removeWhitelistedWallet(wallet.address);
      await expect(
        issuerHelper.connect(whitelister).processLoadAndSafeTransfer(erc20Token.address, wallet.address, ethers.utils.parseUnits("50", 18))
      ).to.be.revertedWith("Wallet is not whitelisted");
    });
  });
});

