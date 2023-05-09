// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import "@openzeppelin/contracts/metatx/MinimalForwarder.sol";

interface IPBMRC2 {
    function loadAndSafeTransfer(address _to, uint256 _amount) external;
}

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

    function _msgSender()
        internal
        view
        virtual
        override(Context, ERC2771Context)
        returns (address)
    {
        return super._msgSender();
    }

    function _msgData()
        internal
        view
        virtual
        override(Context, ERC2771Context)
        returns (bytes calldata)
    {
        return super._msgData();
    }

    // this function will call loadAndSafeTransfer on a target smart contract
    // then call a ERC20 safeTransferFrom to transfer money
    // from a master wallet address to this smart contract
    function processLoadAndSafeTransfer(
        address _erc20Token,
        address _wallet,
        uint256 _amount
    ) external {
        require(whitelistedWallets[_wallet], "Wallet is not whitelisted");
        IERC20(_erc20Token).safeTransferFrom(_wallet, address(this), _amount);
        IPBMRC2(targetPBM).loadAndSafeTransfer(_wallet, _amount);
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
        require(
            allowedWhitelisters[msg.sender],
            "Caller is not an allowed whitelister"
        );
        _;
    }
}
