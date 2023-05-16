// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./PBM.sol";

contract PBMRC2 is PBM {
    constructor(string memory _uriPostExpiry) PBM(_uriPostExpiry) {}

    struct Envelope {
        address to;
        uint256 tokenId;
        uint256 spotAmount;
    }
    // mapping to store the underlying spot token amounts
    // user address => tokenId => Envelope[]
    mapping(address => mapping(uint256 => Envelope[])) public envelopes;

    function loadTo(uint256 tokenId, uint256 amount, address recipient) public {
        // check whether user holds the PBM envelope
        require(
            balanceOf(_msgSender(), tokenId) > 0,
            "PBM: Don't have any PBM to load to."
        );
        // Write the spotAmount to the envelope
        envelopes[msg.sender][tokenId].push(
            Envelope(recipient, tokenId, amount)
        );
        // pull the ERC20 spot token to the PBM
        ERC20Helper.safeTransfer(spotToken, address(this), amount);
    }

    function safeMint(address receiver, uint256 tokenId, uint256 amount, bytes calldata data) public whenNotPaused {
        require(
            !IPBMAddressList(pbmAddressList).isBlacklisted(receiver),
            "PBM: 'to' address blacklisted"
        );
        PBMTokenManager(pbmTokenManager).increaseBalanceSupply(
            serialise(tokenId),
            serialise(amount)
        );
        _mint(receiver, tokenId, amount, data);
    }

    function safeMintBatch(address receiver, uint256[] calldata tokenIds, uint256[] calldata amounts, bytes calldata data) public whenNotPaused{
        require(!IPBMAddressList(pbmAddressList).isBlacklisted(receiver), "PBM: 'to' address blacklisted");
        require(tokenIds.length == amounts.length, "Unequal ids and amounts supplied");

        PBMTokenManager(pbmTokenManager).increaseBalanceSupply(tokenIds, amounts);
        _mintBatch(receiver, tokenIds, amounts, data);
    }

    function underlyingBalanceOf(uint256 tokenId, address user) public view returns (uint256) {
        uint totalSpotAmount = 0;

        for (uint i = 0; i < envelopes[user][tokenId].length; i++) {
            totalSpotAmount += envelopes[user][tokenId][i].spotAmount;
        }

        return totalSpotAmount;
    }

    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) public override(PBM) whenNotPaused {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );
        require(
            !IPBMAddressList(pbmAddressList).isBlacklisted(to),
            "PBM: 'to' address blacklisted"
        );

        if (IPBMAddressList(pbmAddressList).isMerchant(to)) {
            // find the envelope with the same spotAmount
            uint256 spotAmount = abi.decode(data, (uint256));
            uint envelopeIndex;
            Envelope[] storage userEnvelopes = envelopes[from][id];
            for (uint i = 0; i < userEnvelopes.length; i++) {
                if (userEnvelopes[i].spotAmount == spotAmount) {
                    envelopeIndex = i;
                    break;
                }
            }

            ERC20Helper.safeTransfer(spotToken, to, spotAmount);
            _safeTransferFrom(from, to, id, amount, data);

            uint256 lastIndex = userEnvelopes.length - 1;
            // Move the last envelope to the position of the deleted envelope
            userEnvelopes[envelopeIndex] = userEnvelopes[lastIndex];
            // Remove the last envelope
            userEnvelopes.pop();


        delete envelopes[from][id][envelopeIndex];
            emit MerchantPayment(
                from,
                to,
                serialise(id),
                serialise(amount),
                spotToken,
                spotAmount
            );
        } else {
            _safeTransferFrom(from, to, id, amount, data);
        }
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
        require(
            !IPBMAddressList(pbmAddressList).isBlacklisted(to),
            "PBM: 'to' address blacklisted"
        );
        require(
            ids.length == amounts.length,
            "Unequal ids and amounts supplied"
        );

        if (IPBMAddressList(pbmAddressList).isMerchant(to)) {
            uint256 valueOfTokens = 0;
            for (uint256 i = 0; i < ids.length; i++) {
                valueOfTokens += underlyingBalanceOf(ids[i], from);
            }
            ERC20Helper.safeTransfer(spotToken, to, valueOfTokens);
            _safeBatchTransferFrom(from, to, ids, amounts, data);
            emit MerchantPayment(
                from,
                to,
                ids,
                amounts,
                spotToken,
                valueOfTokens
            );
        } else {
            _safeBatchTransferFrom(from, to, ids, amounts, data);
        }
    }

    function uri(
        uint256 tokenId
    ) public view override(PBM) returns (string memory) {
        return PBMTokenManager(pbmTokenManager).uri(tokenId);
    }
}
