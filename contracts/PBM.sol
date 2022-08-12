// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./TokenHelper.sol"; 

// explore transfer helper for managing xsgd transfers

contract PBM is ERC1155, Ownable, ERC1155Burnable, Pausable {  
    using Strings for uint256;
    using SafeMath for uint256 ; 

    address public spotToken ; 
    uint256 public expiry ;  

    uint256 private tokenTypeCount = 0 ; 
    uint256 private tokenSpotValue = 0 ; 

    string private URIPostExpiry ; 


    // constructor argument takes in the token URI. Id needs to be replaces according the voucher type. 
    constructor(string memory tokenUri, string memory uriPostExpiry) ERC1155(tokenUri) {
        URIPostExpiry = uriPostExpiry ; 
    }

    // modifiers
    modifier contractNotExpired() {
        require(block.timestamp<= expiry , "The vouchers have expired");
        _;
    }

    modifier contractExpired() {
        require(block.timestamp >= expiry , "The vouchers have not yet expired");
        _;
    }

    // event definitions
    event payment(address from , address to, uint256 tokenId,  uint256 amount, uint256 value);
    event batchPayment(address from , address to, uint256[] tokenIds, uint256[] amounts, uint256 value); 
    event newTokenTypeCreated(uint256 tokenId, string tokenName, uint256 amount, uint256 expiry); 

    struct TokenConfig {
        string name ; 
        uint256 amount ; 
        uint256 expiry ; 
        address creator ; 
    }

    // whitelisted merchants
    mapping (address => bool) public merchantList; 

    // tokenId mappings
    mapping (uint256 => TokenConfig) internal tokenTypes ; 

    // reverse mapping for lookup
    mapping (string => uint256) internal tokenNameToId; 
    mapping (address => uint256[]) internal tokenCreatorToIds ; 
    
    function initialise (address _spotToken, uint256 _expiry) 
    external 
    onlyOwner
    {
        spotToken = _spotToken ; 
        expiry = _expiry ; 
    }

    // update expiry for the PBM
    function updateExpiry(uint256 _expiry)
    external 
    onlyOwner
    {
        expiry = _expiry; 
    }

    // function to set the the whitelisted merchants.
    function seedMerchantlist(address[] memory addresses)
    external
    onlyOwner
    {
        for (uint256 i = 0; i < addresses.length; i++) {
        merchantList[addresses[i]] = true;
        }
    }

    function getTokenName(uint256 tokenId) public view returns (string memory) {
        return tokenTypes[tokenId].name ; 
    }

    function createTokenType(string memory companyName, uint256 spotAmount, uint256 tokenExpiry) public onlyOwner {
        require(tokenExpiry <= expiry, "Token expiry can not be larger than the contract expriy") ; 
        require(tokenExpiry > block.timestamp , "Token expiry cannot be before the present") ; 
        require(spotAmount != 0 , "Spot amount cannot be 0") ; 
        
        string memory tokenName = string.concat(companyName,spotAmount.toString()) ; 
        tokenTypes[tokenTypeCount].name = tokenName ; 
        tokenTypes[tokenTypeCount].amount = spotAmount ; 
        tokenTypes[tokenTypeCount].expiry = tokenExpiry ; 
        tokenTypes[tokenTypeCount].creator = msg.sender ; 

        tokenNameToId[tokenName] = tokenTypeCount ; 
        tokenCreatorToIds[msg.sender].push(tokenTypeCount) ; 

        emit newTokenTypeCreated(tokenTypeCount, tokenName, spotAmount, expiry);
        tokenTypeCount = uint256(tokenTypeCount.add(1)) ;  
    }

    function getTokenIdFromName(string memory tokenName) public view returns (uint256){
        require(tokenNameToId[tokenName] != 0 , "Invalid token name. Token does not exist") ; 
        return tokenNameToId[tokenName] ; 
    }

    function getTokenIdsFromCreator(address creator) public view returns(uint256[] memory){
        return tokenCreatorToIds[creator] ; 
    }

    function mint(uint256 tokenId, uint256 amount, address receiver) 
    public 
    onlyOwner 
    contractNotExpired
    whenNotPaused
    {
        require(tokenTypes[tokenId].amount != 0 , "The token id is invalid, please create a new token type or use an existing one") ;
        require(tokenTypes[tokenId].expiry > block.timestamp, "The token has expired and cannot be used anymore"); 

        // check if we have the enough spot
        uint256 contractBalance =  TokenHelper.balanceOf(spotToken, address(this));
        uint256 valueOfNewTokens = amount.mul(tokenTypes[tokenId].amount) ; 
        require(tokenSpotValue + valueOfNewTokens <= contractBalance, "The contract does not have the necessary spot to suppor the mint of the new tokens") ; 
        
        // mint the token if the contract holds enough XSGD
        _mint(receiver, tokenId, amount, '');
        tokenSpotValue = tokenSpotValue.add(valueOfNewTokens) ; 
    }

    function mintBatch(uint256[] memory tokenIds, uint256[] memory amounts, address receiver) 
    public 
    onlyOwner
    contractNotExpired
    whenNotPaused
    {   
        require(tokenIds.length == amounts.length, "Different number of Token ids and amounts supplied"); 

        uint256 valueOfNewTokens = 0 ; 
        for (uint256 id = 0; id < tokenIds.length; id++) {
            require(tokenTypes[id].amount != 0 , "The token id is invalid, please create a new token type or use an existing one") ;
            require(tokenTypes[id].expiry > block.timestamp, "The token has expired and cannot be used anymore");
            valueOfNewTokens.add(amounts[id].mul(tokenTypes[id].amount)) ; 
        }


        // check if we have the enough spot
        uint256 contractBalance =  TokenHelper.balanceOf(spotToken, address(this));
        require(tokenSpotValue + valueOfNewTokens <= contractBalance, "The contract does not have the necessary spot to suppor the mint of the new tokens") ; 
        
        // mint the token if the contract holds enough XSGD
        _mintBatch(receiver, tokenIds, amounts, '');
        tokenSpotValue = tokenSpotValue.add(valueOfNewTokens) ; 
    }

    function safeTransferFrom( address from, address to, uint256 id, uint256 amount, bytes memory data) 
    public 
    virtual  
    override
    whenNotPaused 
    contractNotExpired {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );
        require(tokenTypes[id].amount != 0 , "The token id is invalid, please create a new token type or use an existing one") ;
        require(tokenTypes[id].expiry > block.timestamp, "The token has expired and cannot be used anymore"); 

        if (merchantList[to]==true){
            uint256 valueOfTokens = amount.mul(tokenTypes[id].amount) ;
            uint256 contractBalance = TokenHelper.balanceOf(spotToken, address(this));
            require (tokenSpotValue.sub(valueOfTokens) >= contractBalance, "Error: the contract doesn't have enought spot currency, please contact the issuer") ;  

            _burn(from, id, amount);
            TokenHelper.safeTransfer(spotToken, msg.sender, valueOfTokens);
            emit payment(from, to, id, amount, valueOfTokens);


        } else {
            _safeTransferFrom(from, to, id, amount, data);
        }
 
    }
    
    function safeBatchTransferFrom(address from,address to,uint256[] memory ids,uint256[] memory amounts, bytes memory data) 
    public 
    virtual 
    override
    whenNotPaused 
    contractNotExpired
    {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );

        if (merchantList[to]==true){
           require(ids.length == amounts.length, "Different number of token-ids and amounts supplied"); 

            uint256 valueOfTokens = 0 ; 
            for (uint256 id = 0; id < ids.length; id++) {
                require(tokenTypes[id].amount != 0 , "The token id is invalid, please create a new token type or use an existing one") ;
                require(tokenTypes[id].expiry > block.timestamp, "The token has expired and cannot be used anymore");
                valueOfTokens.add(amounts[id].mul(tokenTypes[id].amount)) ; 
            } 

            // check if we have the enough spot
            uint256 contractBalance =  TokenHelper.balanceOf(spotToken, address(this));
            require(tokenSpotValue.sub(valueOfTokens) >= contractBalance, "Error: the contract doesn't have enought spot currency, please contact the issuer") ; 
        
            _burnBatch(from, ids, amounts);
            TokenHelper.safeTransfer(spotToken, msg.sender, valueOfTokens);
            emit batchPayment(from, to, ids, amounts, valueOfTokens);

        } else {
            _safeBatchTransferFrom(from, to, ids, amounts, data);
        }
    }
    
    function withdrawFunds() public onlyOwner contractExpired whenNotPaused {
        uint256 contractBalance =  TokenHelper.balanceOf(spotToken, address(this));
        TokenHelper.safeTransfer(spotToken, msg.sender, contractBalance);

        _setURI(URIPostExpiry);
    }
}