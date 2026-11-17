// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { Test } from "forge-std/Test.sol";
import { StdInvariant } from "forge-std/StdInvariant.sol";
import { SaleToken } from "../src/SaleToken.sol";
import { TokenSale } from "../src/TokenSale.sol";
import { SaleFixture } from "./TokenSale.t.sol";

/// @notice Drives the sale with random buyers, owner actions and a single closing event.
/// @dev Buys happen only while the sale is open; `closeAndSweep` warps past `endTime` once and
///      sets `closed`, so later calls cannot re-enter the sale window (the predecessor's handler
///      jumped to the end and biased every subsequent buy).
contract SaleHandler is Test {
    TokenSale public immutable sale;
    address public immutable owner;
    address public immutable sink = address(0xBEEF);
    uint256 public immutable min;
    uint256 public immutable max;

    address[] public actors;
    bool public closed;

    constructor(TokenSale sale_, address owner_, uint256 min_, uint256 max_) {
        sale = sale_;
        owner = owner_;
        min = min_;
        max = max_;
        for (uint256 i = 0; i < 6; i++) {
            actors.push(makeAddr(string.concat("actor", vm.toString(i))));
        }
    }

    function actorsLength() external view returns (uint256) {
        return actors.length;
    }

    function buy(uint256 actorSeed, uint256 amount) external {
        if (closed) return;
        address actor = actors[actorSeed % actors.length];
        amount = bound(amount, min, max);
        uint256 cost = sale.quote(amount);
        vm.deal(actor, cost);
        vm.prank(actor);
        try sale.buy{ value: cost }(amount) { } catch { }
    }

    function withdraw() external {
        vm.prank(owner);
        try sale.withdrawProceeds(payable(sink)) { } catch { }
    }

    function togglePause(bool on) external {
        vm.startPrank(owner);
        if (on) {
            try sale.pause() { } catch { }
        } else {
            try sale.unpause() { } catch { }
        }
        vm.stopPrank();
    }

    function closeAndSweep(uint256 seed) external {
        if (closed) return;
        if (seed % 10 != 0) return;
        vm.warp(uint256(sale.endTime()) + 1);
        closed = true;
        vm.prank(owner);
        try sale.sweepUnsold(sink) { } catch { }
    }
}

contract TokenSaleInvariantTest is StdInvariant, SaleFixture {
    SaleHandler internal handler;

    function setUp() public override {
        super.setUp();
        handler = new SaleHandler(sale, owner, MIN, MAX);
        targetContract(address(handler));
    }

    /// @notice Balance in the sale + sold + swept always equals the initial inventory.
    function invariant_InventoryIsConserved() public view {
        assertEq(
            token.balanceOf(address(sale)) + sale.totalTokensSold() + sale.totalSweptTokens(),
            INVENTORY
        );
    }

    function invariant_SoldNeverExceedsInventory() public view {
        assertLe(sale.totalTokensSold(), INVENTORY);
    }

    function invariant_SupplyIsFixed() public view {
        assertEq(token.totalSupply(), SUPPLY);
        assertEq(token.balanceOf(treasury), 0);
    }

    function invariant_PositionsMatchTotals() public view {
        uint256 tokens;
        uint256 paid;
        uint256 buyers;
        for (uint256 i = 0; i < handler.actorsLength(); i++) {
            address actor = handler.actors(i);
            uint256 actorTokens = sale.tokensPurchasedBy(actor);
            tokens += actorTokens;
            paid += sale.weiPaidBy(actor);
            if (actorTokens > 0) buyers++;
            assertLe(actorTokens, MAX); // wallet cap
            assertEq(token.balanceOf(actor), actorTokens); // actors never transfer
        }
        assertEq(tokens, sale.totalTokensSold());
        assertEq(paid, sale.totalRaisedWei());
        assertEq(buyers, sale.buyerCount());
    }

    /// @notice POL held by the sale equals raised minus withdrawn.
    function invariant_EtherBalanceMatchesAccounting() public view {
        assertEq(address(sale).balance, sale.totalRaisedWei() - sale.totalWithdrawnWei());
    }

    function invariant_BuyerListHasNoDuplicates() public view {
        uint256 count = sale.buyerCount();
        (address[] memory buyers,,) = sale.getBuyers(0, sale.MAX_PAGE());
        assertEq(buyers.length, count);
        for (uint256 i = 0; i < buyers.length; i++) {
            for (uint256 j = i + 1; j < buyers.length; j++) {
                assertTrue(buyers[i] != buyers[j]);
            }
        }
    }
}
