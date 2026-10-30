// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/// @title Smoke
/// @notice Placeholder used to verify the containerised Foundry toolchain.
/// @dev Replaced by `SaleToken` and `TokenSale` in phase 2. Do not extend this contract.
contract Smoke {
    /// @notice Toolchain identifier, useful in smoke tests and `cast` calls.
    function version() external pure returns (string memory) {
        return "dapp-tk-basic/toolchain";
    }
}
