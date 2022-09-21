# Purpose Bound Money (PBM) - Commercial

## Token Description
PBM or Purpose Bound Money is a protocol that implements a purpose layer in the form of smart contract code which specifies the conditions upon which an underlying digital currency can be used. The purpose layer could be programmed whereby the PBM can only be utilized (only) for its intended purposes, such as validity within a certain period, at specific retailers, and in predetermined denominations. Once the conditions specified in the Purpose Layer is met, the underlying backing currency will be released, and transferred to the recipient. 

When the conditions of a PBM is fulfilled, the underlying digital currency backing the PBM is released, and ownership is transferred to the target recipient. To fulfil the requirements to be a backing currency, a digital asset needs to be a good store of value, unit of account and a medium of exchange. Backing currency could come in the form of CBDCs, tokenised deposits or securely backed stablecoins. A backing currency could be in the form of a programmable money, whereby the digital currency itself could come with a set of usage criteria. For example, the backing currency could be implemented as an ERC-20 fungible token smart contract.

This implmentation of the PBM is developed to support mulitple issuers, issuing different PBM types each with their own configuration. It was designed to be piloted at large scale public event, where different sponors could issue their own PBMs through one singular contract which could be spent at on-site F&B stores for food. 

## Smart Contract Specifications
The PBM smart contract has built upon the ERC-1155 token standard leveraging its semi-fungible nature. Since each issued PBM type can have multiple copies, the ERC-1155 allows for the most efficient data managment. 

The PBM is built with two contracts. The PBM.sol contains all the ERC-1155 NFT logic, preserving information on ownership, transfers, etc. The PBMTokenManager.sol is designed as database storing details about each of PBM token type. 

As a developer/user, you just have to interact the PBM.sol contract, the deployment and managment of the PBMTokenManager.sol is taken care of by the PBM.sol contract. 

## PBM.

### Roles and Privileges

| Name | Description & Privileges |
|--|--|
|`owner`| The owner (deployer initially) of the PBM contract. The `owner` handles critical administrative actions, e.g., extending expiry, managing merchant list, pausing, `creating new token types`, etc.|
|`issuer`| Third parties who have created new token types. To issue a new PBM type the third party, must first verify the details of the PBM with the `owner`. The `owner` upon verifcation can create a new token type on behalf of the `issuer`, with the `issuer` address stored on the contract. The `issuer` is also tasked with locking up the neccessary ERC20 tokens and minting the new tokens.|
|`consumer`| Third parties who aren't `issuers` are able to hold and transfer the PBMs like NFTs. They are also able to use these PBM ( before expiry ) to pay at specific merchant sites.|

### Immutable Fields
The table below presents the immutable fields of the token contract and a description of what it is for.

| Name | Type | Description |
|--|--|--|
| `spotToken` | `address` | Address of the underlying digtial currency ( ERC-20 tokens only ) |
| `pbmTokenManager` | `address` | Address of the PBMTokenManager contract, that fixed upon deployment of `PBM.sol`.|

### Mutable Fields
The table below presents the mutable fields of the token contract and a description of what it is for.

| Name | Type | Description |
|--|--|--|
| `contractExpiry` | `uint256` | Time (in epoch) when the PBM contract expires. |
| `merchantList` | `mapping (address => bool)` | The list of whitelisted Merchants who (only) are able to recieve the wrapped up digital Tokens. |


##### Pausable

The entire contract can be frozen, in the event a serious bug is found or if there is a key compromise. No transfers can take place while the contract is paused. Access to the pause functionality is controlled by the `owner` address.

## PBM Token Manager

| Name | Description & Privileges |
|--|--|
|`owner`| The owner (The `PBM` contract that deployed the token manager) of the PBM contract. The `owner` is the only addres who has access to the `write` actions to the PBM details.|

### Immutable Fields
The table below presents the immutable fields of the token contract and a description of what it is for.

| Name | Type | Description |
|--|--|--|
| `URIPostExpiry` | `string` | URI which returns the metadata for the PBMs after they expiry. |

### Mutable Fields
The table below presents the mutable fields of the token contract and a description of what it is for.

| Name | Type | Description |
|--|--|--|
| `tokenTypes` | `admapping (uint256 => TokenConfig)` | Mapping of tokenIds to the different PBM token details.|

####  TokenConfig Data structure 
The TokenConfig stores the different details about the PBM tokens.
```
    struct TokenConfig {
        string name ; 
        uint256 amount ; 
        uint256 expiry ; 
        address creator ; 
        uint256 balanceSupply ; 
        string uri ; 
    }
    
```