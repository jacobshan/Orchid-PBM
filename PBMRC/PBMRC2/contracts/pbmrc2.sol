// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../contracts/PBM.sol";

contract PBMRC2 is PBM {
    

    // This function load will take ERC20 token from a specified wallet address and move it into 
    // this smart contract
    // We will subsequently track how much ERC20 token has been taken for a particular user address
    // and for which user's tokenId 
    // <CODE HERE>

    // this function loadAndSafeTransfer will call the function load, and upon success, call safeTransferFrom 
    // to the target wallet address
    // <CODE HERE>

}