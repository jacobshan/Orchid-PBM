// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./PBM.sol";

contract PBMRC2 is PBM("") {
    mapping(uint256 => uint256) public PBMDiscounts;

    constructor() {
        PBMDiscounts[1] = 5; // 5 XSGD discount for Token ID 1
        PBMDiscounts[2] = 20; // 10 XSGD discount for Token ID 2
    }

    function getDiscountAmount(
        address user,
        uint256 tokenId,
        uint256 amount
    ) public view returns (uint256) {
        require(balanceOf(user, tokenId) > 0, "User does not have the PBM.");

        uint256 discount = PBMDiscounts[tokenId];
        uint256 discountedAmount = amount - discount;

        return discountedAmount;
    }

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
