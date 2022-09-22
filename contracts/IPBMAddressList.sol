// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title PBM Address list Interface. 
/// @notice The PBM address list stores and manages whitelisted merchants and blacklisted address for the PBMs 
interface IPBMAddressList {

    /// @notice Adds wallet addresses to the blacklist who are unable to receive the pbm tokens.
    /// @param addresses The list of merchant wallet address
    function blacklistAddresses(address[] memory addresses) external; 

    /// @notice Removes wallet addresses from the blacklist who are  unable to receive the PBM tokens.
    /// @param addresses The list of merchant wallet address
    function unBlacklistAddresses(address[] memory addresses) external; 

    /// @notice Checks if the address is one of the blacklisted addresses
    /// @param _address The address in query
    /// @return True if address is a blacklisted, else false
    function isBlacklisted(address _address) external returns (bool) ; 

    /// @notice Adds wallet addresses of merchants who are the only wallets able to receive the underlying ERC-20 tokens (whitelisting).
    /// @param addresses The list of merchant wallet address
    function addMerchantAddresses(address[] memory addresses) external; 

    /// @notice Removes wallet addresses from the merchant addresses who are  able to receive the underlying ERC-20 tokens (un-whitelisting).
    /// @param addresses The list of merchant wallet address
    function removeMerchantAddresses(address[] memory addresses) external; 

    /// @notice Checks if the address is one of the whitelisted merchant
    /// @param _address The address in query
    /// @return True if address is a merchant, else false
    function isMerchant(address _address) external returns (bool) ; 
}