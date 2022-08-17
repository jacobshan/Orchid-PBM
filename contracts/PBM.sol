// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./TokenHelper.sol"; 

contract PBM is ERC1155, Ownable, ERC1155Burnable, Pausable {  
    using Strings for uint256;
    using SafeMath for uint256 ; 

    address public spotToken ; 
    uint256 public expiry ;  

    uint256 private tokenTypeCount = 0 ; 
    uint256 private spotValueOfAllExistingTokens = 0 ; 
    bool public initilased = false ; 

    string private URIPostExpiry ; 

    // constructor argument takes in the token URI. Id needs to be replaces according the voucher type. 
    constructor(string memory uriPostExpiry) ERC1155("") {
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
    event newTokenTypeCreated(uint256 tokenId, string tokenName, uint256 amount, uint256 expiry, address creator); 

    struct TokenConfig {
        string name ; 
        uint256 amount ; 
        uint256 expiry ; 
        address creator ; 
        string uri ; 
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
        require(!initilased, "Token has already been initialised"); 
        spotToken = _spotToken ; 
        expiry = _expiry ; 
        initilased = true ; 
    }

    function getSpotValueOfAllExistingTokens()
    external 
    onlyOwner
    view
    returns (uint256)
    {
        return spotValueOfAllExistingTokens ; 
    }

    // extend expiry for the PBM
    function extendExpiry(uint256 extendedExpiry)
    external 
    onlyOwner
    {   
        require(extendedExpiry > expiry, "New expiry must be larger than the current" ) ; 
        expiry = extendedExpiry; 
    }

    // function to set the the whitelisted merchants.
    function seedMerchantList(address[] memory addresses)
    external
    onlyOwner
    {
        for (uint256 i = 0; i < addresses.length; i++) {
        merchantList[addresses[i]] = true;
        }
    }

    function createTokenType(string memory companyName, uint256 spotAmount, uint256 tokenExpiry, string memory tokenURI) public onlyOwner {
        require(tokenExpiry <= expiry, "Token expiry can't exceed contract expriy") ; 
        require(tokenExpiry > block.timestamp , "Token expiry should be in the future") ; 
        require(spotAmount != 0 , "Spot amount cannot be 0") ; 
        
        string memory tokenName = string(abi.encodePacked(companyName,spotAmount.toString())) ; 
        tokenTypes[tokenTypeCount].name = tokenName ; 
        tokenTypes[tokenTypeCount].amount = spotAmount ; 
        tokenTypes[tokenTypeCount].expiry = tokenExpiry ; 
        tokenTypes[tokenTypeCount].creator = msg.sender ; 
        tokenTypes[tokenTypeCount].uri = tokenURI ; 

        tokenNameToId[tokenName] = tokenTypeCount ; 
        tokenCreatorToIds[msg.sender].push(tokenTypeCount) ; 

        emit newTokenTypeCreated(tokenTypeCount, tokenName, spotAmount, expiry, msg.sender);
        tokenTypeCount = uint256(tokenTypeCount.add(1)) ;  
    }

    function getTokenDetails(uint256 tokenId) public view returns (string memory, uint256, uint256, address) {
        return (tokenTypes[tokenId].name, tokenTypes[tokenId].amount, tokenTypes[tokenId].expiry, tokenTypes[tokenId].creator) ; 
    }

    function getTokenIdFromName(string memory tokenName) public view returns (uint256){
        return tokenNameToId[tokenName] ; 
    }

    function getTokenIdsFromCreator(address creator) public view returns(uint256[] memory){
        return tokenCreatorToIds[creator] ; 
    }

    function uri(uint256 id) public view virtual override returns (string memory) {
        return tokenTypes[id].uri ; 
    }

    function mint(uint256 tokenId, uint256 amount, address receiver) 
    public 
    onlyOwner 
    contractNotExpired
    whenNotPaused
    {
        require(tokenTypes[tokenId].amount != 0 , "Invalid token id(s)") ;
        require(tokenTypes[tokenId].expiry > block.timestamp, "Token(s) expired"); 

        // check if we have the enough spot
        uint256 contractBalance =  TokenHelper.balanceOf(spotToken, address(this));
        uint256 valueOfNewTokens = amount.mul(tokenTypes[tokenId].amount) ; 
        require(spotValueOfAllExistingTokens.add(valueOfNewTokens) <= contractBalance, "Insufficient spot tokens") ; 
        
        // mint the token if the contract holds enough XSGD
        _mint(receiver, tokenId, amount, '');
        spotValueOfAllExistingTokens = spotValueOfAllExistingTokens.add(valueOfNewTokens) ; 
    }

    function mintBatch(uint256[] memory tokenIds, uint256[] memory amounts, address receiver) 
    public 
    onlyOwner
    contractNotExpired
    whenNotPaused
    {   
        require(tokenIds.length == amounts.length, "Unequal ids and amounts supplied"); 

        uint256 valueOfNewTokens = 0 ; 
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(tokenTypes[tokenIds[i]].amount != 0 , "Invalid token id(s)") ;
            require(tokenTypes[tokenIds[i]].expiry > block.timestamp, "Token(s) expired");
            valueOfNewTokens = valueOfNewTokens.add(amounts[i].mul(tokenTypes[tokenIds[i]].amount)) ; 
        } 

        // check if we have the enough spot
        uint256 contractBalance =  TokenHelper.balanceOf(spotToken, address(this));
        require(spotValueOfAllExistingTokens.add(valueOfNewTokens) <= contractBalance, "Insufficient spot tokens") ; 
        
        // mint the token if the contract holds enough XSGD
        _mintBatch(receiver, tokenIds, amounts, '');
        spotValueOfAllExistingTokens = spotValueOfAllExistingTokens.add(valueOfNewTokens) ; 
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
        require(tokenTypes[id].amount != 0 , "Invalid token id(s)") ;
        require(tokenTypes[id].expiry > block.timestamp, "Token(s) expired"); 

        if (merchantList[to]==true){
            uint256 valueOfTokens = amount.mul(tokenTypes[id].amount) ;
            uint256 contractBalance = TokenHelper.balanceOf(spotToken, address(this));
            require (spotValueOfAllExistingTokens.sub(valueOfTokens) < contractBalance, "Insufficient spot tokens") ;  

            _burn(from, id, amount);
            TokenHelper.safeTransfer(spotToken, to, valueOfTokens);
            spotValueOfAllExistingTokens = spotValueOfAllExistingTokens.sub(valueOfTokens) ; 
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
        require(ids.length == amounts.length, "Unequal ids and amounts supplied"); 

        if (merchantList[to]==true){
            uint256 valueOfTokens = 0 ; 
            for (uint256 i = 0; i < ids.length; i++) {
                require(tokenTypes[ids[i]].amount != 0 , "Invalid token id(s)") ;
                require(tokenTypes[ids[i]].expiry > block.timestamp, "Token(s) expired");
                valueOfTokens = valueOfTokens.add(amounts[i].mul(tokenTypes[ids[i]].amount)) ; 
            } 
            // check if we have the enough spot
            uint256 contractBalance =  TokenHelper.balanceOf(spotToken, address(this));
            require(spotValueOfAllExistingTokens.sub(valueOfTokens) < contractBalance, "Insufficient spot tokens") ; 
        
            _burnBatch(from, ids, amounts);
            TokenHelper.safeTransfer(spotToken, to, valueOfTokens);
            spotValueOfAllExistingTokens = spotValueOfAllExistingTokens.sub(valueOfTokens); 
            emit batchPayment(from, to, ids, amounts, valueOfTokens);

        } else {
            for (uint256 i = 0; i < ids.length; i++) {
                require(tokenTypes[ids[i]].amount != 0 , "Invalid token id(s)") ;
                require(tokenTypes[ids[i]].expiry > block.timestamp, "Token(s) expired");
            } 
            _safeBatchTransferFrom(from, to, ids, amounts, data);
        }
    }
    
    function withdrawFunds() public onlyOwner contractExpired whenNotPaused {
        uint256 contractBalance =  TokenHelper.balanceOf(spotToken, address(this));
        TokenHelper.safeTransfer(spotToken, msg.sender, contractBalance);

        _setURI(URIPostExpiry);
    }
}