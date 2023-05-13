// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./PBM.sol";

contract PBMRC2 is PBM("") {

    constructor() {}

    function loadTo(uint256 tokenId, address to, uint256 amount) public {
        // Wrap the spotAmount to the envelope
        envelopes[msg.sender][to].push(Envelope(tokenId, amount));
        // pull the ERC20 spot token to the PBM
        ERC20Helper.safeTransfer(spotToken, address(this), amount);
    }


}
