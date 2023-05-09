---
title: Purpose bound money
description: An interface extending EIP-1155 for <placeholder>, supporting use case such as <placeholder>
author: Victor Liew (@Alcedo)
discussions-to: https://ethereum-magicians.org (Create a discourse here for early feedback)
status:  DRAFT
type: Standards Track
category: ERC
created: 2023-04-01
requires: 165, 1155
---

## Abstract
This PBMRC outlines a smart contract interface that builts upon the [ERC-1155](./eip-1155.md) standard borrowing many of the ideas introduced by it including support for multiple tokens within the same contract and batch operations. 

This EIP defines an interface to  <placeholder>

## Motivation


Digital assets sometimes need to be consumaed. One of the most common examples is a voucher AKA Purpose bound money ticket.

PBM needs to be unwrapped / consumed for <placeholder>

Having a standard interface enables interoperability for services, clients, UI, and inter-contract functionalities on top of this use-case.

## Specification

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and “OPTIONAL” in this document are to be interpreted as described in RFC 2119.

1. Any compliant contract **MUST** implement the following interface:

```solidity
pragma solidity >=0.7.0 <0.9.0;

/// The IPBMRC1 identifier of this interface is  <placeholder 0xdd123123> 

interface IPBMRC1 {
    /// @notice The unwrap function  <placeholder>  <placeholder>  <placeholder>
    /// @param documentation 
    function unWrap(
        address _consumer,
        uint256 _assetId,
        uint256 _amount,
        bytes calldata _data
    ) external returns (bool _success);

}
```

2. If the compliant contract is an  [EIP-1155](./eip-1155.md) token, in addition to `OnConsumption`, it **MUST** also emit the `Transfer` / `TransferSingle` event (as applicable) as if a token has been transferred from the current holder to the zero address if the call to `consume` method succeeds.

3. `supportsInterface(placeholder 0xdd123123)` **MUST** return `true` for any compliant contract, as per [EIP-165](./eip-165.md).

## Rationale

1. The function `unWrap` performs the consume / unwrapping of wrapped tokens action. This EIP does not assume:

- who has the power to perform consumption
- under what condition consumption can occur

It does, however, assume the asset can be identified in a `uint256` asset id as in the parameter. A design convention and compatibility consideration is put in place to follow the EIP-721 pattern.

2. The event notifies subscribers whoever are interested to learn an asset is being consumed.

3. To keep it simple, this standard *intentionally* contains no functions or events related to the creation of a consumable asset. because of XYZ

4. Metadata associated to the consumables is not included the standard. If necessary, related metadata can be created with a separate metadata extension interface like `ERC721Metadata` from [EIP-721](./eip-721.md)

or refer to opensea 

5. MAYBE We choose to include an `address consumer` for `consume` function and `isConsumableBy` so that an NFT MAY be consumed for someone other than the transaction initiator.

6. We choose to include an extra `_data` field for future extension, such as
adding crypto endorsements.

7. We explicitly stay opinion-less about whether EIP-721 or EIP-1155 shall be required because
while we design this EIP with EIP-721 and EIP-1155 in mind mostly, we don't want to rule out
the potential future case someone use a different token standard or use it in different use cases.


## Backwards Compatibility

This interface is designed to be compatible with EIP-721 and NFT of EIP-1155. It can be tweaked to used for [EIP-20](./eip-20.md), [EIP-777](./eip-777.md) and Fungible Token of EIP-1155.

## Test Cases

```ts

  describe("Consumption", function () {
    it("Should consume when minted", async function () {
      const fakeTokenId = "0x1234";
      const { contract, addr1 } = await loadFixture(deployFixture);
      await expect(contract.ownerOf(fakeTokenId))
        .to.be.rejectedWith('ERC721: invalid token ID');
      await expect(contract.isConsumableBy(addr1.address, fakeTokenId, 1))
        .to.be.rejectedWith('ERC721: invalid token ID');
    });
  });

  describe("EIP-165 Identifier", function () {
    it("Should match", async function () {
      const { contract } = await loadFixture(deployFixture);
      expect(await contract.get165()).to.equal(" ");
      expect(await contract.supportsInterface(" ")).to.be.true;
    });
  });
```

## Reference Implementation



## Security Considerations
Compliant contracts should pay attention to the balance change when a token is consumed.
When the contract is being paused, or the user is being restricted from transferring a token,
the unWrapping function should be consistent with the transferal restriction.

Compliant contracts should also carefully define access control, particularly whether any EOA or contract account may or may not initiate a `unWrap` method in their own use case.

Security audits and tests should be used to verify that the access control to the `consume`
function behaves as expected, or if any customized business logic is being used. 





## Copyright

Copyright and related rights waived via [CC0](../LICENSE.md).