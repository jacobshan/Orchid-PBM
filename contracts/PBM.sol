// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/lifecycle/Pausable.sol";
import "./TransferHelper.sol"; 

// explore transfer helper for managing xsgd transfers

contract PBM is ERC1155, Ownable, ERC1155Burnable, Pausable {  
    using Strings for uint256;

    // constructor argument takes in the token URI. Id needs to be replaces according the voucher type. 
    constructor() ERC1155("https://game.example/api/item/{id}.json") {}

    // modifiers
    modifier vouchersNotExpired() {
        require(block.timestamp<= expiry , "The vouchers have expired");
        _;
    }

    modifier vouchersExpired() {
        require(block.timestamp >= expiry , "The vouchers have not yet expired");
        _;
    }

    // spot contract address - proxy contract address for xsgd
    address spotContract = 0xDC3326e71D45186F113a2F448984CA0e8D201995; 

    // event definitions
    event spotTransfer(uint256 tokenId, uint256 amount, address to);

    // tokenId mappings, enter the different types of vouchers ahead of time
    uint256 grab_vouchers_1$ = 1;
    uint256 grab_vouchers_5$ = 2; 
    uint256 ocbc_vouchers_5$ = 3; 
    uint256 sff_vouchers_5$ = 4; 

    // data strctures to 
    mapping (uint256 => string) tokenUri;
    mapping (address => bool) public merchantList; 
    mapping (uint256 => uint256) public tokenid;

    uint256 expiry = 1234143123 ; // Update epoch as necessary 
    
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

    function mint(address receiver) public onlyOwner returns (uint256) {
        // To do: Implement based on documentation
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override whenNotPaused {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );
        // To Do: Implement based on doucmentation
        // _safeTransferFrom(from, to, id, amount, data);
    }
    
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override whenNotPaused {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );
        // To Do: Implement based on doucmentation
        //_safeBatchTransferFrom(from, to, ids, amounts, data);
    }
    
    function unwrapSpot (address merchantAddress, uint256 spotAmount) internal whenNotPaused {
       // To Do: Implement based on doucmentation 
       externalContract spotTokenContract = externalContract(spotContract);
    }

    function withdrawFunds() public onlyOwner vouchersExpired {
        // To do : implement based on documentation
    }
}