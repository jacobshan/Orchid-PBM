const { expect } = require("chai");
const { ethers } = require("hardhat");
const { signMetaTxRequest } = require("../src/signer");

async function deploy(name, ...params) {
  const Contract = await ethers.getContractFactory(name);
  return await Contract.deploy(...params).then(f => f.deployed());
}

describe("IssuerHelper", function () {
  beforeEach(async function () {
    // Deploy a mock ERC20 token
    this.erc20Token = await deploy("Spot");

    // Deploy the PBMRC2 contract
    this.pbmrc2 = await deploy("PBMRC2");

    // Deploy the MinimalForwarder contract
    this.minimalForwarder = await deploy("MinimalForwarder");

    // Deploy the IssuerHelper contract
    this.issuerHelper = await deploy("IssuerHelper", this.pbmrc2.address, this.minimalForwarder.address);


    // Get the signers
    [owner, whitelister, wallet, other] = await ethers.getSigners();

    await this.issuerHelper.addWhitelister(owner.address);

    // Add the whitelister and wallet as allowed entities
    await this.issuerHelper.addWhitelister(whitelister.address);
    await this.issuerHelper.addWhitelistedWallet(wallet.address);

    // Give the wallet some tokens
    await this.erc20Token.mint(wallet.address, ethers.utils.parseUnits("1000", 18));
  });

  async function relay(forwarder, request, signature, whitelist) {
    // Decide if we want to relay this request based on a whitelist
    const accepts = !whitelist || whitelist.includes(request.to);
    if (!accepts) throw new Error(`Rejected request to ${request.to}`);

    // Validate request on the forwarder contract
    const valid = await forwarder.verify(request, signature);

    if (!valid) throw new Error(`Invalid request`);

    // Send meta-tx through relayer to the forwarder contract
    const gasLimit = (parseInt(request.gas) * 1.5).toString();
    return await forwarder.execute(request, signature, { gasLimit });
  }

  describe("meta txn", function () {
    it("should call the addWhitelistedWallet thru a metatxn", async function () {
      const { minimalForwarder, issuerHelper } = this;

      const { request, signature } = await signMetaTxRequest(whitelister.provider, minimalForwarder, {
        from: whitelister.address,
        to: issuerHelper.address,
        data: issuerHelper.interface.encodeFunctionData('addWhitelistedWallet', [other.address]),
      });

      const whitelist = [issuerHelper.address]

      // Check whitelister's initial ether balance
      const initialWhitelisterBalance = await ethers.provider.getBalance(whitelister.address);

      await relay(minimalForwarder, request, signature, whitelist);

      // Check whitelister's final ether balance
      const finalWhitelisterBalance = await ethers.provider.getBalance(whitelister.address);
      expect(await issuerHelper.whitelistedWallets(other.address)).to.equal(true);

      // Compare initial and final balances to ensure that whitelister didn't pay gas
      expect(initialWhitelisterBalance).to.equal(finalWhitelisterBalance);

    })

    it("should fail if caller is not an allowed whitelister", async function () {
      const { minimalForwarder, issuerHelper } = this;
      const { request, signature } = await signMetaTxRequest(other.provider, minimalForwarder, {
        from: other.address,
        to: issuerHelper.address,
        data: issuerHelper.interface.encodeFunctionData('addWhitelistedWallet', [other.address]),
      });
      const whitelist = [issuerHelper.address]

      // Check other's initial ether balance
      const initialOtherBalance = await ethers.provider.getBalance(other.address);

      await relay(minimalForwarder, request, signature, whitelist);

      // Check other's final ether balance
      const finalOtherBalance = await ethers.provider.getBalance(other.address);

      // Compare initial and final balances to ensure that other didn't pay gas
      expect(initialOtherBalance).to.equal(finalOtherBalance);

      // based on the forwarder contract implementation 
      // here the excute function call would finish 
      // but the underlying addWhitelistedWallet function call of this meta txn would be reverted
      // and the state of the issuer helper contract would remain unchanged
      // the returndata returned by the execute function would contain the revert reason
      // and the error message emitted by the underlying function call
      // in order to inspect the returndata might need to emit an event in the execute function call
      // will leave it to the forwarder contract implenmentor to figure out the details

      expect(await issuerHelper.whitelistedWallets(other.address)).to.equal(false);
    });

    it("should call the processLoadAndSafeTransfer thru a metatxn", async function () {
      const { erc20Token, issuerHelper, minimalForwarder } = this;
      // Grant allowance to the issuerHelper contract by the wallet
      await erc20Token.connect(wallet).approve(issuerHelper.address, ethers.utils.parseUnits("100", 18));

      // Check the initial balances
      const initialIssuerHelperBalance = await erc20Token.balanceOf(issuerHelper.address);
      const initialWalletBalance = await erc20Token.balanceOf(wallet.address);

      // Perform the processLoadAndSafeTransfer metatxn call
      const { request, signature } = await signMetaTxRequest(wallet.provider, minimalForwarder, {
        from: wallet.address,
        to: issuerHelper.address,
        data: issuerHelper.interface.encodeFunctionData('processLoadAndSafeTransfer', [erc20Token.address, wallet.address, ethers.utils.parseUnits("50", 18)]),
      });

      const whitelist = [issuerHelper.address]

      // Check wallet's initial ether balance
      const initialWalletEthBalance = await ethers.provider.getBalance(wallet.address);

      await relay(minimalForwarder, request, signature, whitelist);

      // Check wallet's final ether balance
      const finalWalletEthBalance = await ethers.provider.getBalance(wallet.address);

      // Compare initial and final balances to ensure that other didn't pay gas
      expect(initialWalletEthBalance).to.equal(finalWalletEthBalance);

      // Check the final balances
      const finalIssuerHelperBalance = await erc20Token.balanceOf(issuerHelper.address);
      const finalWalletBalance = await erc20Token.balanceOf(wallet.address);
      expect(finalIssuerHelperBalance.sub(initialIssuerHelperBalance)).to.equal(ethers.utils.parseUnits("50", 18));
      expect(initialWalletBalance.sub(finalWalletBalance)).to.equal(ethers.utils.parseUnits("50", 18));
    })

  })

  describe("processLoadAndSafeTransfer", function () {
    it("should transfer tokens from wallet to IssuerHelper and call loadAndSafeTransfer on PBMRC2", async function () {
      const { erc20Token, issuerHelper } = this;
      // Grant allowance to the issuerHelper contract by the wallet
      await erc20Token.connect(wallet).approve(issuerHelper.address, ethers.utils.parseUnits("100", 18));

      // Check the initial balances
      const initialIssuerHelperBalance = await erc20Token.balanceOf(issuerHelper.address);
      const initialWalletBalance = await erc20Token.balanceOf(wallet.address);

      // Check wallet's initial ether balance
      const initialWalletEthBalance = await ethers.provider.getBalance(wallet.address);
      // Perform the processLoadAndSafeTransfer function call
      txn = await issuerHelper.connect(wallet).processLoadAndSafeTransfer(erc20Token.address, wallet.address, ethers.utils.parseUnits("50", 18));
      receipt = await txn.wait();

      // Calculate the gas used and cost
      const gasUsed = receipt.gasUsed;
      const gasPrice = txn.gasPrice;
      const gasCost = gasUsed.mul(gasPrice);

      // Check wallet's final ether balance
      const finalWalletEthBalance = await ethers.provider.getBalance(wallet.address);

      // Check if the wallet's Ether balance changes equal to the gas used for the transaction
      expect(initialWalletEthBalance.sub(finalWalletEthBalance)).to.equal(gasCost);

      // Check the final balances
      const finalIssuerHelperBalance = await erc20Token.balanceOf(issuerHelper.address);
      const finalWalletBalance = await erc20Token.balanceOf(wallet.address);
      expect(finalIssuerHelperBalance.sub(initialIssuerHelperBalance)).to.equal(ethers.utils.parseUnits("50", 18));
      expect(initialWalletBalance.sub(finalWalletBalance)).to.equal(ethers.utils.parseUnits("50", 18));
    });

    it("should fail if caller is not an allowed whitelister", async function () {
      const { issuerHelper } = this;
      await expect(
        issuerHelper.connect(other).addWhitelistedWallet(wallet.address)
      ).to.be.revertedWith("Caller is not an allowed whitelister");
    });

    it("should fail if wallet is not whitelisted", async function () {
      const { issuerHelper, erc20Token } = this;
      await issuerHelper.removeWhitelistedWallet(wallet.address);
      await expect(
        issuerHelper.connect(whitelister).processLoadAndSafeTransfer(erc20Token.address, wallet.address, ethers.utils.parseUnits("50", 18))
      ).to.be.revertedWith("Wallet is not whitelisted");
    });
  });
});

