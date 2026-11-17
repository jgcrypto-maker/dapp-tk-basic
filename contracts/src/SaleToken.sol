// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title SaleToken
/// @notice Fixed-supply ERC-20 minted once at construction: `inventory` goes to the sale
///         contract and the remainder to the treasury. No mint, burn, fees or admin afterwards.
/// @dev Deployed by `TokenSale` (ADR-02/ADR-14), so the inventory always lives in the sale
///      contract from the first block and deployment is atomic.
contract SaleToken is ERC20 {
    error InvalidSupply();
    error ZeroAddress();

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_,
        address inventoryHolder,
        uint256 inventory,
        address treasury
    ) ERC20(name_, symbol_) {
        if (inventoryHolder == address(0) || treasury == address(0)) {
            revert ZeroAddress();
        }
        if (totalSupply_ == 0 || inventory == 0 || inventory > totalSupply_) {
            revert InvalidSupply();
        }

        _mint(inventoryHolder, inventory);
        if (totalSupply_ > inventory) _mint(treasury, totalSupply_ - inventory);
    }
}
