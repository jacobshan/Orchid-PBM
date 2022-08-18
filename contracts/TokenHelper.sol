// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.6.0;

// import '../interfaces/IERC20Minimal.sol';
import "@openzeppelin/contracts/interfaces/IERC20.sol";

/// @title TokenHelper
/// @notice Contains helper methods for interacting with ERC20 tokens that do not consistently return true/false
library TokenHelper {
    /// @notice Transfers tokens from msg.sender to a recipient
    /// @dev Calls transfer on token contract, errors with TF if transfer fails
    /// @param token The contract address of the token which will be transferred
    /// @param to The recipient of the transfer
    /// @param value The value of the transfer
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "Interaction with the spot token failed.");
    }

    function balanceOf(address token, address user) internal returns (uint256) {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.balanceOf.selector, user));
        require(success, "Interaction with the spot token failed.");
        return abi.decode(data, (uint256));
    }
}
