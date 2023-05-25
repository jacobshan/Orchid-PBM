// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./PBM.sol";

contract PBMRC2 is PBM {
    constructor() PBM() {}

    event TokenLoad(
        address caller,
        address to,
        uint256 tokenId,
        uint256 amount,
        address ERC20Token,
        uint256 ERC20TokenValue
    );
    event TokenUnload(
        address caller,
        address from,
        uint256 tokenId,
        uint256 amount,
        address ERC20Token,
        uint256 ERC20TokenValue
    );

    function load(uint256 tokenId, uint256 amount, address caller) public returns (uint256) {
        ERC20Helper.safeTransferFrom(spotToken, msg.sender, address(this), amount);
        // load function doesn't specify the underlying token recipient use 0 address as a place holder
        uint256 envelopeId = PBMTokenManager(pbmTokenManager).loadHelper(caller, tokenId, amount, address(0));
        emit TokenLoad(caller, address(0), tokenId, amount, spotToken, amount);
        return envelopeId;
    }

    function loadTo(uint256 tokenId, uint256 amount, address recipient, address caller) public returns (uint256) {
        require(balanceOf(caller, tokenId) > 0, "PBM: Doesn't have enough PBM.");
        // pull the ERC20 spot token to the PBM
        ERC20Helper.safeTransferFrom(spotToken, msg.sender, address(this), amount);
        uint256 envelopeId = PBMTokenManager(pbmTokenManager).loadHelper(caller, tokenId, amount, recipient);
        emit TokenLoad(caller, recipient, tokenId, 1, spotToken, amount);
        return envelopeId;
    }

    function unload(uint256 tokenId, uint256 amount, address caller) public {
        require(balanceOf(caller, tokenId) >= 0, "PBM: Doesn't have enough PBM.");
        PBMTokenManager(pbmTokenManager).unloadHelper(caller, tokenId, amount);
        ERC20Helper.safeTransferFrom(spotToken, address(this), msg.sender, amount);
        emit TokenUnload(caller, address(this), tokenId, 1, spotToken, amount);
    }

    function mint(uint256 tokenId, uint256 amount, address receiver) public override whenNotPaused {
        PBMTokenManager(pbmTokenManager).mintHelper(tokenId, amount, receiver, pbmAddressList);
        _mint(receiver, tokenId, amount, "");
    }

    function batchMint(
        uint256[] calldata tokenIds,
        uint256[] calldata amounts,
        address receiver
    ) public override whenNotPaused {
        PBMTokenManager(pbmTokenManager).batchMintHelper(tokenIds, amounts, receiver, pbmAddressList);
        _mintBatch(receiver, tokenIds, amounts, "");
    }

    function underlyingBalanceOf(uint256 tokenId, uint256 envelopId, address user) public view returns (uint256) {
        return PBMTokenManager(pbmTokenManager).underlyingBalanceOf(tokenId, envelopId, user);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        uint256 amount,
        bytes memory data
    ) public override(PBM) whenNotPaused {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );
        require(!IPBMAddressList(pbmAddressList).isBlacklisted(to), "PBM: 'to' address blacklisted");

        if (IPBMAddressList(pbmAddressList).isMerchant(to)) {
            uint256 envelopeId = abi.decode(data, (uint256));
            uint256 spotAmount = PBMTokenManager(pbmTokenManager).getLoadedAmountAndRedeem(from, tokenId, envelopeId);
            ERC20Helper.safeTransfer(spotToken, to, spotAmount);
            emit MerchantPayment(from, to, serialise(tokenId), serialise(amount), spotToken, spotAmount);
        }
        _safeTransferFrom(from, to, tokenId, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public override(PBM) whenNotPaused {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );
        require(!IPBMAddressList(pbmAddressList).isBlacklisted(to), "PBM: 'to' address blacklisted");
        require(ids.length == amounts.length, "Unequal ids and amounts supplied");

        if (IPBMAddressList(pbmAddressList).isMerchant(to)) {
            uint256[] memory envelopesIds = abi.decode(data, (uint256[]));
            uint256 spotAmounts = PBMTokenManager(pbmTokenManager).getLoadedAmountsAndRedeem(from, ids, envelopesIds);
            ERC20Helper.safeTransfer(spotToken, to, spotAmounts);
            emit MerchantPayment(from, to, ids, amounts, spotToken, spotAmounts);
        }
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }
}
