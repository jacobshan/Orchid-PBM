// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../contracts/PBM.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IPBMRC2 { 

    // function load
    // function loadAndSafeTransfer

}

contract PBMRC2 is PBM, IPBMRC2 {
    // mapping(address => mapping(uint256 => uint256)) public userTokenBalances;

    // function load(address user, uint256 tokenId, uint256 amount) external {
    //     // Transfer ERC20 tokens from the user's wallet to this smart contract
    //     IERC20(spotToken).transferFrom(user, address(this), amount);

    //     // Update the user's balance for the specified tokenId
    //     userTokenBalances[user][tokenId] += amount;
    // }

    // function loadAndSafeTransfer(address from, uint256 tokenId, uint256 amount, address to) external {
    //     // Call the load function to transfer ERC20 tokens and update the balance
    //     load(from, tokenId, amount);

    //     // Call safeTransferFrom to transfer the loaded tokens to the target wallet address
    //     // safeTransferFrom should trigger the business logic checks before paying the merchant
           // it should also keep records of cashback details, and original user. 
    //     safeTransferFrom(from, to, tokenId, amount, "");
    //     
    //     
    // }
}
