// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IPBMTokenManager.sol";
import "./NoDelegateCall.sol";
import "./IPBMAddressList.sol";

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PBMTokenManager is Ownable, IPBMTokenManager, NoDelegateCall {
    using Strings for uint256;

    // counter used to create new token types
    uint256 internal tokenTypeCount = 0;

    // structure representing all the details of a PBM type
    struct TokenConfig {
        string name;
        uint256 amount;
        uint256 expiry;
        address creator;
        uint256 balanceSupply;
        string uri;
        string postExpiryURI;
    }

    // mapping of token ids to token details
    mapping(uint256 => TokenConfig) internal tokenTypes;

    enum EnvelopeStatus {
        NONE,
        LOADED,
        REDEEMED,
        UNLOADED
    }

    uint256 internal envelopeCount = 0;

    struct Envelope {
        address to;
        uint256 spotAmount;
        EnvelopeStatus status;
    }
    // user address => tokenId => envelopeId => Envelope
    mapping(address => mapping(uint256 => mapping(uint256 => Envelope))) public envelopes;

    // user address => tokenId => envelopeIds
    mapping(address => mapping(uint256 => uint256[])) public envelopeIds;

    constructor() {}

    /**
     * @dev See {IPBMTokenManager-createPBMTokenType}.
     *
     * Requirements:
     *
     * - caller must be owner ( PBM contract )
     * - contract must not be expired
     * - token expiry must be less than contract expiry
     * - `amount` should not be 0
     */
    function createTokenType(
        string memory companyName,
        uint256 spotAmount,
        uint256 tokenExpiry,
        address creator,
        string memory tokenURI,
        string memory postExpiryURI,
        uint256 contractExpiry
    ) external override onlyOwner noDelegateCall {
        require(tokenExpiry <= contractExpiry, "Invalid token expiry-1");
        require(tokenExpiry > block.timestamp, "Invalid token expiry-2");
        require(spotAmount != 0, "Spot amount is 0");

        string memory tokenName = string(abi.encodePacked(companyName, spotAmount.toString()));
        tokenTypes[tokenTypeCount].name = tokenName;
        tokenTypes[tokenTypeCount].amount = spotAmount;
        tokenTypes[tokenTypeCount].expiry = tokenExpiry;
        tokenTypes[tokenTypeCount].creator = creator;
        tokenTypes[tokenTypeCount].balanceSupply = 0;
        tokenTypes[tokenTypeCount].uri = tokenURI;
        tokenTypes[tokenTypeCount].postExpiryURI = postExpiryURI;

        emit NewPBMTypeCreated(tokenTypeCount, tokenName, spotAmount, tokenExpiry, creator);
        tokenTypeCount += 1;
    }

    /**
     * @dev See {IPBMTokenManager-revokePBM}.
     *
     * Requirements:
     *
     * - caller must be owner ( PBM contract )
     * - token must be expired
     * - `tokenId` should be a valid id that has already been created
     * - `sender` must be the token type creator
     */
    function revokePBM(uint256 tokenId, address sender) external override onlyOwner {
        require(
            sender == tokenTypes[tokenId].creator && block.timestamp >= tokenTypes[tokenId].expiry,
            "PBM not revokable"
        );
        tokenTypes[tokenId].balanceSupply = 0;
    }

    /**
     * @dev See {IPBMTokenManager-increaseBalanceSupply}.
     *
     * Requirements:
     *
     * - caller must be owner ( PBM contract )
     * - `tokenId` should be a valid id that has already been created
     * - `sender` must be the token type creator
     */
    function increaseBalanceSupply(uint256[] memory tokenIds, uint256[] memory amounts) public override onlyOwner {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(
                tokenTypes[tokenIds[i]].amount != 0 && block.timestamp < tokenTypes[tokenIds[i]].expiry,
                "PBM: Invalid Token Id(s)"
            );
            tokenTypes[tokenIds[i]].balanceSupply += amounts[i];
        }
    }

    /**
     * @dev See {IPBMTokenManager-decreaseBalanceSupply}.
     *
     * Requirements:
     *
     * - caller must be owner ( PBM contract )
     * - `tokenId` should be a valid id that has already been created
     * - `sender` must be the token type creator
     */
    function decreaseBalanceSupply(uint256[] memory tokenIds, uint256[] memory amounts) public override onlyOwner {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(
                tokenTypes[tokenIds[i]].amount != 0 && block.timestamp < tokenTypes[tokenIds[i]].expiry,
                "PBM: Invalid Token Id(s)"
            );
            tokenTypes[tokenIds[i]].balanceSupply -= amounts[i];
        }
    }

    /**
     * @dev See {IPBMTokenManager-uri}.
     *
     */
    function uri(uint256 tokenId) external view override returns (string memory) {
        if (block.timestamp >= tokenTypes[tokenId].expiry) {
            return tokenTypes[tokenId].postExpiryURI;
        }
        return tokenTypes[tokenId].uri;
    }

    /**
     * @dev See {IPBMTokenManager-areTokensValid}.
     *
     */
    function areTokensValid(uint256[] memory tokenIds) external view override returns (bool) {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            if (block.timestamp > tokenTypes[i].expiry || tokenTypes[i].amount == 0) {
                return false;
            }
        }
        return true;
    }

    /**
     * @dev See {IPBMTokenManager-getTokenDetails}.
     *
     * Requirements:
     *
     * - `tokenId` should be a valid id that has already been created
     */
    function getTokenDetails(
        uint256 tokenId
    ) external view override returns (string memory, uint256, uint256, address) {
        require(tokenTypes[tokenId].amount != 0, "PBM: Invalid Token Id(s)");
        return (
            tokenTypes[tokenId].name,
            tokenTypes[tokenId].amount,
            tokenTypes[tokenId].expiry,
            tokenTypes[tokenId].creator
        );
    }

    /**
     * @dev See {IPBMTokenManager-getPBMRevokeValue}.
     *
     * Requirements:
     *
     * - `tokenId` should be a valid id that has already been created
     */
    function getPBMRevokeValue(uint256 tokenId) external view override returns (uint256) {
        require(tokenTypes[tokenId].amount != 0, "PBM: Invalid Token Id(s)");
        return tokenTypes[tokenId].amount * tokenTypes[tokenId].balanceSupply;
    }

    /**
     * @dev See {IPBMTokenManager-getTokenValue}.
     *
     * Requirements:
     *
     * - `tokenId` should be a valid id that has already been created
     */
    function getTokenValue(uint256 tokenId) external view override returns (uint256) {
        require(
            tokenTypes[tokenId].amount != 0 && block.timestamp < tokenTypes[tokenId].expiry,
            "PBM: Invalid Token Id(s)"
        );
        return tokenTypes[tokenId].amount;
    }

    /**
     * @dev See {IPBMTokenManager-getTokenCount}.
     *
     * Requirements:
     *
     * - `tokenId` should be a valid id that has already been created
     */
    function getTokenCount(uint256 tokenId) external view override returns (uint256) {
        require(
            tokenTypes[tokenId].amount != 0 && block.timestamp < tokenTypes[tokenId].expiry,
            "PBM: Invalid Token Id(s)"
        );
        return tokenTypes[tokenId].balanceSupply;
    }

    /**
     * @dev See {IPBMTokenManager-getTokenCreator}.
     *
     * Requirements:
     *
     * - `tokenId` should be a valid id that has already been created
     */
    function getTokenCreator(uint256 tokenId) external view override returns (address) {
        require(
            tokenTypes[tokenId].amount != 0 && block.timestamp < tokenTypes[tokenId].expiry,
            "PBM: Invalid Token Id(s)"
        );
        return tokenTypes[tokenId].creator;
    }

    function mintHelper(uint256 tokenId, uint256 amount, address receiver, address pbmAddressList) public {
        require(!IPBMAddressList(pbmAddressList).isBlacklisted(receiver), "PBM: 'to' address blacklisted");
        increaseBalanceSupply(serialise(tokenId), serialise(amount));
    }

    function batchMintHelper(
        uint256[] memory tokenIds,
        uint256[] memory amounts,
        address receiver,
        address pbmAddressList
    ) public {
        require(!IPBMAddressList(pbmAddressList).isBlacklisted(receiver), "PBM: 'to' address blacklisted");
        require(tokenIds.length == amounts.length, "Unequal ids and amounts supplied");
        increaseBalanceSupply(tokenIds, amounts);
    }

    function loadHelper(address caller, uint256 tokenId, uint256 amount, address recipient) public returns (uint256) {
        // Write the spotAmount to the envelope
        envelopes[caller][tokenId][envelopeCount] = Envelope(recipient, amount, EnvelopeStatus.LOADED);
        uint256 envelopeId = envelopeCount;
        // Write the envelopeId to the user address to envelopeIds map
        envelopeIds[caller][tokenId].push(envelopeId);
        envelopeCount += 1;
        return envelopeId;
    }

    function unloadHelper(address caller, uint256 tokenId, uint256 amount) public {
        uint256[] memory ownedEnvelopeIds = envelopeIds[caller][tokenId];
        uint256 unloadId;
        for (uint256 i = 0; i < ownedEnvelopeIds.length; i++) {
            if (envelopes[caller][tokenId][ownedEnvelopeIds[i]].spotAmount == amount) {
                envelopes[caller][tokenId][ownedEnvelopeIds[i]].status = EnvelopeStatus.UNLOADED;
                unloadId = ownedEnvelopeIds[i];
                break;
            }
        }
        require(unloadId != 0, "PBM: No envelope with the given amount found");
    }

    function underlyingBalanceOf(uint256 tokenId, uint256 envelopId, address user) public view returns (uint256) {
        return envelopes[user][tokenId][envelopId].spotAmount;
    }

    function getLoadedAmountAndRedeem(address from, uint256 tokenId, uint256 envelopeId) public returns (uint256) {
        require(envelopes[from][tokenId][envelopeId].status == EnvelopeStatus.LOADED, "PBM: Envelope not loaded");
        uint256 spotAmount = envelopes[from][tokenId][envelopeId].spotAmount;
        envelopes[from][tokenId][envelopeId].status = EnvelopeStatus.REDEEMED;
        return spotAmount;
    }

    function getLoadedAmountsAndRedeem(
        address from,
        uint256[] memory tokenIds,
        uint256[] memory envelopesIds
    ) public returns (uint256) {
        require(tokenIds.length == envelopesIds.length, "Unequal tokenIds and envelopIds supplied");
        uint256 spotAmounts = 0;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(
                envelopes[from][tokenIds[i]][envelopesIds[i]].status == EnvelopeStatus.LOADED,
                "PBM: Envelope not loaded"
            );
            spotAmounts += envelopes[from][tokenIds[i]][envelopesIds[i]].spotAmount;
            envelopes[from][tokenIds[i]][envelopesIds[i]].status = EnvelopeStatus.REDEEMED;
        }
        return spotAmounts;
    }

    function serialise(uint256 num) internal pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = num;
        return array;
    }
}
