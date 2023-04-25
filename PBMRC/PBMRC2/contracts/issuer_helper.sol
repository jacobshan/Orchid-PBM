// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IPBM {
    function loadAndPay(address _to, uint256 _amount) external;
}

contract IssuerHelper is Ownable {
    using SafeERC20 for IERC20;

    // list of whitelisted wallet addresses that 
    // has granted PBM approval to this smart contract.
    mapping(address => bool) public whitelistedWallets;

    // store an address reference to the target PBM
    IPBM public targetPBM;

    // list of allowedWhitelister to call functions on this smart contract
    mapping(address => bool) public allowedWhitelisters;

    constructor(address _targetPBM) {
        targetPBM = IPBM(_targetPBM);
    }

    // this function will call loadAndPay on a target smart contract at an address
    // this function will then call a ERC20 safeTransferFrom to transfer money from a t
    // target wallet address to this smart contract
    // check that the target smart address has implemented loadAndPay
    function processLoadAndPay(address _erc20Token, address _wallet, uint256 _amount) external onlyWhitelister {
        require(whitelistedWallets[_wallet], "Wallet is not whitelisted");
        IERC20(_erc20Token).safeTransferFrom(_wallet, address(this), _amount);
        targetPBM.loadAndPay(_wallet, _amount);
    }

    function addWhitelistedWallet(address _wallet) external onlyOwner {
        whitelistedWallets[_wallet] = true;
    }

    function removeWhitelistedWallet(address _wallet) external onlyOwner {
        whitelistedWallets[_wallet] = false;
    }

    function addWhitelister(address _whitelister) external onlyOwner {
        allowedWhitelisters[_whitelister] = true;
    }

    function removeWhitelister(address _whitelister) external onlyOwner {
        allowedWhitelisters[_whitelister] = false;
    }

    modifier onlyWhitelister() {
        require(allowedWhitelisters[msg.sender], "Caller is not an allowed whitelister");
        _;
    }
}
