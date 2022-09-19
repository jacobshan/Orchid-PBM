// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; 

import "./IPBMTokenManager.sol";
import "./NoDelegateCall.sol";

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PBMTokenManager is Ownable, IPBMTokenManager, NoDelegateCall {
    using Strings for uint256;

    uint256 private tokenTypeCount = 0 ; 

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

    function revokePBM(uint256 tokenId, address sender)
    external
    override
    onlyOwner
    {
        
        require (sender == tokenTypes[tokenId].creator && block.timestamp >= tokenTypes[tokenId].expiry, "PBM not revokable") ;
        tokenTypes[tokenId].balanceSupply = 0 ; 
    }

    function increaseBalanceSupply(uint256[] memory tokenIds, uint256[] memory amounts)
    external
    override
    onlyOwner
    {   
        for (uint256 i = 0; i < tokenIds.length; i++) {
            tokenTypes[tokenIds[i]].balanceSupply += amounts[i] ;
        }
    }

    function decreaseBalanceSupply(uint256[] memory tokenIds, uint256[] memory amounts)
    external 
    override
    onlyOwner
    {   
        for (uint256 i = 0; i < tokenIds.length; i++) {
            tokenTypes[tokenIds[i]].balanceSupply -= amounts[i] ;
        }
    }

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

    function getTokenDetails(uint256 tokenId) 
    external 
    override
    view 
    returns (string memory, uint256, uint256, address) 
    {
        return (tokenTypes[tokenId].name, tokenTypes[tokenId].amount, tokenTypes[tokenId].expiry, tokenTypes[tokenId].creator) ; 
    }

    function getTokenValue(uint256 tokenId)
    external 
    override
    view 
    returns (uint256) {
        return tokenTypes[tokenId].amount ; 
    }

    function getTokenCount(uint256 tokenId)
    external 
    override
    view 
    returns (uint256) {
        return tokenTypes[tokenId].balanceSupply ; 
    }

    function getTokenCreator(uint256 tokenId)
    external 
    override
    view 
    returns (address) {
        return tokenTypes[tokenId].creator ; 
    }
}