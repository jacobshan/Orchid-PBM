// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; 

import "./IPBMTokenManager.sol";
import "./NoDelegateCall.sol";

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

import "./ERC20Helper.sol";
import "./IPBMAddressList.sol";

contract PBMTokenManager is Ownable, IPBMTokenManager, NoDelegateCall {
    using Strings for uint256;

    // counter used to create new token types
    uint256 internal tokenTypeCount = 0 ; 

    // structure representing all the details of a PBM type
    struct TokenConfig {
        string name ; 
        uint256 amount ; 
        uint256 expiry ; 
        address creator ; 
        uint256 balanceSupply ; 
        string uri ; 
    }

    // URI for tokens after expiry
    string  internal  URIPostExpiry ; 

    // mapping of token ids to token details
    mapping (uint256 => TokenConfig) internal tokenTypes ; 

    constructor(string memory _uriPostExpiry){
        URIPostExpiry = _uriPostExpiry ; 
    }

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
    function createTokenType(string memory companyName, uint256 spotAmount, uint256 tokenExpiry, address creator, string memory tokenURI, uint256 contractExpiry) 
    external 
    override 
    onlyOwner
    noDelegateCall
    {   
        require(tokenExpiry <= contractExpiry, "Invalid token expiry-1") ; 
        require(tokenExpiry > block.timestamp , "Invalid token expiry-2") ; 
        require(spotAmount != 0 , "Spot amount is 0") ;  

        string memory tokenName = string(abi.encodePacked(companyName,spotAmount.toString())) ; 
        tokenTypes[tokenTypeCount].name = tokenName ; 
        tokenTypes[tokenTypeCount].amount = spotAmount ; 
        tokenTypes[tokenTypeCount].expiry = tokenExpiry ; 
        tokenTypes[tokenTypeCount].creator = creator ; 
        tokenTypes[tokenTypeCount].balanceSupply = 0 ; 
        tokenTypes[tokenTypeCount].uri = tokenURI ; 

        emit NewPBMTypeCreated(tokenTypeCount, tokenName, spotAmount, tokenExpiry, creator);
        tokenTypeCount += 1 ;
    }

    /**
 * @dev See {IPBM-mint}.
     *
     * IMPT: Before minting, the caller should approve the contract address to spend ERC-20 tokens on behalf of the caller.
     *       This can be done by calling the `approve` or `increaseMinterAllowance` functions of the ERC-20 contract and specifying `_spender` to be the PBM contract address.
             Ref : https://eips.ethereum.org/EIPS/eip-20

       WARNING: Any contracts that externally call these mint() and batchMint() functions should implement some sort of reentrancy guard procedure (such as OpenZeppelin's ReentrancyGuard).
     *
     * Requirements:
     *
     * - contract must not be paused
     * - tokens must not be expired
     * - `tokenId` should be a valid id that has already been created
     * - caller should have the necessary amount of the ERC-20 tokens required to mint
     * - caller should have approved the PBM contract to spend the ERC-20 tokens
     * - receiver should not be blacklisted
     */
    function mintHelper(address pbmAddressList, uint256 tokenId, uint256 amount, address receiver)
    external returns (uint256)
    {
        require(!IPBMAddressList(pbmAddressList).isBlacklisted(receiver), "PBM: 'to' address blacklisted");
        uint256 valueOfNewTokens = amount*getTokenValue(tokenId);
        increaseBalanceSupply(serialise(tokenId), serialise(amount));
        return valueOfNewTokens;
    }

    /**
 * @dev See {IPBM-batchMint}.
     *
     * IMPT: Before minting, the caller should approve the contract address to spend ERC-20 tokens on behalf of the caller.
     *       This can be done by calling the `approve` or `increaseMinterAllowance` functions of the ERC-20 contract and specifying `_spender` to be the PBM contract address.
             Ref : https://eips.ethereum.org/EIPS/eip-20

       WARNING: Any contracts that externally call these mint() and batchMint() functions should implement some sort of reentrancy guard procedure (such as OpenZeppelin's ReentrancyGuard).
     *
     * Requirements:
     *
     * - contract must not be paused
     * - tokens must not be expired
     * - `tokenIds` should all be valid ids that have already been created
     * - `tokenIds` and `amounts` list need to have the same number of values
     * - caller should have the necessary amount of the ERC-20 tokens required to mint
     * - caller should have approved the PBM contract to spend the ERC-20 tokens
     * - receiver should not be blacklisted
     */
    function batchMintHelper(address pbmAddressList, uint256[] memory tokenIds, uint256[] memory amounts, address receiver)
    external returns (uint256)
    {
        require(!IPBMAddressList(pbmAddressList).isBlacklisted(receiver), "PBM: 'to' address blacklisted");
        require(tokenIds.length == amounts.length, "Unequal ids and amounts supplied");

        // calculate the value of the new tokens
        uint256 valueOfNewTokens = 0 ;

        for (uint256 i = 0; i < tokenIds.length; i++) {
            valueOfNewTokens += (amounts[i]*getTokenValue(tokenIds[i]));
        }

        // Transfer spot tokenf from user to contract to wrap it
        increaseBalanceSupply(tokenIds, amounts);
        return valueOfNewTokens;
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
    function revokePBM(uint256 tokenId, address sender)
    external
    override
    onlyOwner
    {
        
        require (sender == tokenTypes[tokenId].creator && block.timestamp >= tokenTypes[tokenId].expiry, "PBM not revokable") ;
        tokenTypes[tokenId].balanceSupply = 0 ; 
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
    function increaseBalanceSupply(uint256[] memory tokenIds, uint256[] memory amounts)
    public
    override
    onlyOwner
    {  
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(tokenTypes[tokenIds[i]].amount!=0 && block.timestamp < tokenTypes[tokenIds[i]].expiry, "PBM: Invalid Token Id(s)"); 
            tokenTypes[tokenIds[i]].balanceSupply += amounts[i] ;
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
    function decreaseBalanceSupply(uint256[] memory tokenIds, uint256[] memory amounts)
    external 
    override
    onlyOwner
    {   
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(tokenTypes[tokenIds[i]].amount!=0 && block.timestamp < tokenTypes[tokenIds[i]].expiry, "PBM: Invalid Token Id(s)"); 
            tokenTypes[tokenIds[i]].balanceSupply -= amounts[i] ;
        }
    }

    /**
     * @dev See {IPBMTokenManager-uri}.
     *
     */ 
    function uri(uint256 tokenId)
    external
    override
    view
    returns (string memory)
    {
        if (block.timestamp >= tokenTypes[tokenId].expiry){
            return URIPostExpiry ; 
        }
        return tokenTypes[tokenId].uri ; 
    }

    /**
     * @dev See {IPBMTokenManager-areTokensValid}.
     *
     */ 
    function areTokensValid(uint256[] memory tokenIds) 
    external 
    override
    view 
    returns (bool) {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            if (block.timestamp > tokenTypes[i].expiry || tokenTypes[i].amount == 0){
                return false ; 
            }
        } 
        return true ; 
    }   

    /**
     * @dev See {IPBMTokenManager-getTokenDetails}.
     *
     * Requirements:
     *
     * - `tokenId` should be a valid id that has already been created
     */ 
    function getTokenDetails(uint256 tokenId) 
    external 
    override
    view 
    returns (string memory, uint256, uint256, address) 
    {
        require(tokenTypes[tokenId].amount!=0, "PBM: Invalid Token Id(s)"); 
        return (tokenTypes[tokenId].name, tokenTypes[tokenId].amount, tokenTypes[tokenId].expiry, tokenTypes[tokenId].creator) ; 
    }

    /**
 * @dev See {IPBMTokenManager-getTokenDetailsByIds}.
     *
     * Requirements:
     *
     * - `tokenIds` should be valid ids that have already been created
     */
    function getTokenDetailsByIds(uint256[] memory tokenIds)
    external
    override
    view
    returns (uint256[] memory ids, string[] memory names, uint256[] memory spotAmounts, uint256[] memory expiry, address[] memory creators )
    {

        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(tokenTypes[tokenIds[i]].amount!=0, "PBM: Invalid Token Id(s)");
            ids[i] = tokenIds[i];
            names[i] = tokenTypes[tokenIds[i]].name;
            spotAmounts[i] = tokenTypes[tokenIds[i]].amount;
            expiry[i] = tokenTypes[tokenIds[i]].expiry;
            creators[i] = tokenTypes[tokenIds[i]].creator;
        }

        return (ids, names, spotAmounts, expiry, creators);
    }

    /**
     * @dev See {IPBMTokenManager-getPBMRevokeValue}.
     *
     * Requirements:
     *
     * - `tokenId` should be a valid id that has already been created
     */ 
    function getPBMRevokeValue(uint256 tokenId)
    external 
    override 
    view 
    returns (uint256)
    {
        require(tokenTypes[tokenId].amount!=0, "PBM: Invalid Token Id(s)"); 
        return tokenTypes[tokenId].amount*tokenTypes[tokenId].balanceSupply; 
    }

    /**
     * @dev See {IPBMTokenManager-getTokenValue}.
     *
     * Requirements:
     *
     * - `tokenId` should be a valid id that has already been created
     */ 
    function getTokenValue(uint256 tokenId)
    public
    override
    view 
    returns (uint256) {
        require(tokenTypes[tokenId].amount!=0 && block.timestamp < tokenTypes[tokenId].expiry, "PBM: Invalid Token Id(s)"); 
        return tokenTypes[tokenId].amount ; 
    }

    /**
     * @dev See {IPBMTokenManager-getTokenCount}.
     *
     * Requirements:
     *
     * - `tokenId` should be a valid id that has already been created
     */ 
    function getTokenCount(uint256 tokenId)
    external 
    override
    view 
    returns (uint256) {
        require(tokenTypes[tokenId].amount!=0 && block.timestamp < tokenTypes[tokenId].expiry, "PBM: Invalid Token Id(s)"); 
        return tokenTypes[tokenId].balanceSupply ; 
    }

    /**
     * @dev See {IPBMTokenManager-getTokenCreator}.
     *
     * Requirements:
     *
     * - `tokenId` should be a valid id that has already been created
     */ 
    function getTokenCreator(uint256 tokenId)
    external 
    override
    view 
    returns (address) {
        require(tokenTypes[tokenId].amount!=0 && block.timestamp < tokenTypes[tokenId].expiry, "PBM: Invalid Token Id(s)"); 
        return tokenTypes[tokenId].creator ; 
    }

    function serialise(uint256 num)
    public
    pure
    returns (uint256[] memory) {
        uint256[] memory array  = new uint256[](1) ;
        array[0] = num ;
        return array ;
    }
}