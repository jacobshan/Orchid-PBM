// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

import "./ERC20Helper.sol";  
import "./PBMTokenManager.sol"; 

contract PBM is ERC1155, Ownable, Pausable {  

    address public spotToken ; 
    uint256 public contractExpiry ; 
    mapping (address => bool) public merchantList ; 

    string private uriPostExpiry ; 
    address public pbmTokenManager; 
    
    event merchantPayment(address from , address to, uint256[] tokenIds, uint256[] amounts, uint256 value); 
    event PBMrevokeWithdraw(address beneficiary, uint256 PBMTokenId, address ERC20Token, uint256 ERC20TokenValue);


    constructor(address _spotToken, uint256 _expiry, string memory _uriPostExpiry) ERC1155("") {
        spotToken = _spotToken ;
        contractExpiry = _expiry ; 

        pbmTokenManager = address(new PBMTokenManager(_uriPostExpiry)) ; 
    }
    
    function extendPBMExpiry(uint256 extendedExpiry)
    external 
    onlyOwner
    whenNotPaused
    {   
        require(block.timestamp < contractExpiry, "PBM: contract is expired");
        require(extendedExpiry > contractExpiry, "PBM : invalid expiry" ) ; 
        contractExpiry = extendedExpiry; 
    }

    function addMerchantAddresses(address[] memory addresses) 
    external
    onlyOwner
    {
        require(block.timestamp < contractExpiry, "PBM: contract is expired");
        for (uint256 i = 0; i < addresses.length; i++) {
            merchantList[addresses[i]] = true;
        }
    }  

    function removeMerchantAddresses(address[] memory addresses) 
    external 
    onlyOwner
    {
        require(block.timestamp < contractExpiry, "PBM: contract is expired");
        for (uint256 i = 0; i < addresses.length; i++) {
            merchantList[addresses[i]] = false;
        } 
    }

    function createPBMTokenType(string memory companyName, uint256 spotAmount, uint256 tokenExpiry,address creator, string memory tokenURI) 
    external 
    onlyOwner 
    {        
        PBMTokenManager(pbmTokenManager).createTokenType(companyName, spotAmount, tokenExpiry, creator,  tokenURI, contractExpiry);
    }

    function mint(uint256 tokenId, uint256 amount, address receiver) 
    external  
    whenNotPaused
    {
        require(PBMTokenManager(pbmTokenManager).areTokensValid(serialise(tokenId)), "PBM: Invalid token id provided");
        uint256 valueOfNewTokens = amount*(PBMTokenManager(pbmTokenManager).getTokenValue(tokenId)); 

        //Transfer the spot token from the user to the contract to wrap it
        ERC20Helper.safeTransferFrom(spotToken, msg.sender, address(this), valueOfNewTokens);

        // mint the token if the contract - wrapping the xsgd
        PBMTokenManager(pbmTokenManager).increaseBalanceSupply(serialise(tokenId), serialise(amount)) ; 
        _mint(receiver, tokenId, amount, ''); 
    }

    function batchMint(uint256[] memory tokenIds, uint256[] memory amounts, address receiver) 
    external 
    whenNotPaused
    {   
        require(tokenIds.length == amounts.length, "Unequal ids and amounts supplied"); 

        // calculate the value of the new tokens
        uint256 valueOfNewTokens = 0 ; 
        require(PBMTokenManager(pbmTokenManager).areTokensValid(tokenIds), "PBM: Invalid token id(s) provided");

        for (uint256 i = 0; i < tokenIds.length; i++) {
            valueOfNewTokens += (amounts[i]*(PBMTokenManager(pbmTokenManager).getTokenValue(tokenIds[i])));  
        } 

        // Transfer spot tokenf from user to contract to wrap it
        ERC20Helper.safeTransferFrom(spotToken, msg.sender, address(this), valueOfNewTokens);
        PBMTokenManager(pbmTokenManager).increaseBalanceSupply(tokenIds, amounts);
        _mintBatch(receiver, tokenIds, amounts, '');
    }

    function safeTransferFrom( address from, address to, uint256 id, uint256 amount, bytes memory data) 
    public   
    override
    whenNotPaused  
    {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );

        require(PBMTokenManager(pbmTokenManager).areTokensValid(serialise(id)), "PBM: Invalid token id provided");

        if (merchantList[to]){
            uint256 valueOfTokens = amount*(PBMTokenManager(pbmTokenManager).getTokenValue(id)); 

            // burn and transfer underlying ERC-20
            _burn(from, id, amount);
            PBMTokenManager(pbmTokenManager).decreaseBalanceSupply(serialise(id), serialise(amount)) ; 
            ERC20Helper.safeTransfer(spotToken, to, valueOfTokens);
            emit merchantPayment(from, to, serialise(id), serialise(amount), valueOfTokens);

        } else {
            _safeTransferFrom(from, to, id, amount, data);
        }
 
    }
    
    function safeBatchTransferFrom(address from,address to,uint256[] memory ids,uint256[] memory amounts, bytes memory data) 
    public  
    override
    whenNotPaused 
    {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );
        require(ids.length == amounts.length, "Unequal ids and amounts supplied"); 
        require(PBMTokenManager(pbmTokenManager).areTokensValid(ids), "PBM: Invalid token id(s) provided");

        if (merchantList[to]){
            uint256 valueOfTokens = 0 ; 
            for (uint256 i = 0; i < ids.length; i++) {
                valueOfTokens += (amounts[i]*(PBMTokenManager(pbmTokenManager).getTokenValue(ids[i]))) ; 
            } 

            _burnBatch(from, ids, amounts);
            PBMTokenManager(pbmTokenManager).decreaseBalanceSupply(ids, amounts);
            ERC20Helper.safeTransfer(spotToken, to, valueOfTokens);

            emit merchantPayment(from, to, ids, amounts, valueOfTokens);

        } else {
            _safeBatchTransferFrom(from, to, ids, amounts, data);
        }
    }
    
    function revokePBM(uint256 tokenId) 
    external 
    whenNotPaused 
    {
        uint256 PBMTokenBalanceSupply = PBMTokenManager(pbmTokenManager).getTokenCount(tokenId); 
        uint256 valueOfTokens = PBMTokenBalanceSupply*(PBMTokenManager(pbmTokenManager).getTokenValue(tokenId)); 

        PBMTokenManager(pbmTokenManager).revokePBM(tokenId, msg.sender); 

        // transfering underlying ERC20 tokens
        ERC20Helper.safeTransfer(spotToken, msg.sender, valueOfTokens);

        emit PBMrevokeWithdraw(msg.sender, tokenId, spotToken, valueOfTokens);

    }

    function getTokenDetails(uint256 tokenId) 
    external 
    view 
    returns (string memory, uint256, uint256, address) 
    {
        return PBMTokenManager(pbmTokenManager).getTokenDetails(tokenId); 
    }

    function uri(uint256 tokenId)
    public  
    view
    override(ERC1155)
    returns (string memory)
    {
        return PBMTokenManager(pbmTokenManager).uri(tokenId);
    }

    function serialise(uint256 num)
    internal 
    pure
    returns (uint256[] memory) {
        uint256[] memory array  = new uint256[](1) ; 
        array[0] = num ; 
        return array ;
    }
}