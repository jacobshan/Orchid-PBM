// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./PBM.sol";

contract PBMRC2 is PBM("") {
    mapping(uint256 => uint256) public PBMDiscounts;

    constructor() {}

    function loadAndSafeTransfer(address _to, uint256 _amount) public {
        // business logic here
    }

    function mintPBMRC2(
        uint256 tokenId,
        uint256 amount,
        address receiver
    ) external {
        _mint(receiver, tokenId, amount, "");
    }
}
