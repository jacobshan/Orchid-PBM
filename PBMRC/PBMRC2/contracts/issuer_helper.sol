// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import "@openzeppelin/contracts/metatx/MinimalForwarder.sol";
import "./IPBMRC2.sol";

contract IssuerHelper is ERC2771Context, Ownable {
    using SafeERC20 for IERC20;

    // list of whitelisted wallet addresses that
    // has granted PBM approval to this smart contract.
    mapping(address => bool) public whitelistedWallets;

    // store an address reference to the target PBM
    address public targetPBM;

    // list of allowedWhitelister to call functions on this smart contract
    mapping(address => bool) public allowedWhitelisters;

    constructor(address _targetPBM, address _trustedForwarder) ERC2771Context(_trustedForwarder) {
        targetPBM = _targetPBM;
    }

    function _msgSender() internal view virtual override(Context, ERC2771Context) returns (address) {
        return super._msgSender();
    }

    function _msgData() internal view virtual override(Context, ERC2771Context) returns (bytes calldata) {
        return super._msgData();
    }

    function processLoadToAndSafeTransferFrom(
        address erc20Token,
        address wallet,
        address recipient,
        uint256 tokenId,
        uint256 amount
    ) external {
        require(whitelistedWallets[wallet], "Wallet is not whitelisted");
        // transfer the ERC20 token from user to helper
        IERC20(erc20Token).safeTransferFrom(wallet, address(this), amount);

        IPBMRC2(targetPBM).loadTo(tokenId, amount, wallet);

        bytes memory data = abi.encode(amount);

        IPBMRC2(targetPBM).safeTransferFrom(address(this), recipient, tokenId, amount, data);
    }

    function addWhitelistedWallet(address _wallet) external onlyWhitelister {
        whitelistedWallets[_wallet] = true;
    }

    function removeWhitelistedWallet(address _wallet) external onlyWhitelister {
        whitelistedWallets[_wallet] = false;
    }

    function addWhitelister(address _whitelister) external onlyOwner {
        allowedWhitelisters[_whitelister] = true;
    }

    function removeWhitelister(address _whitelister) external onlyOwner {
        allowedWhitelisters[_whitelister] = false;
    }

    modifier onlyWhitelister() {
        require(allowedWhitelisters[_msgSender()], "Caller is not an allowed whitelister");
        _;
    }
}
