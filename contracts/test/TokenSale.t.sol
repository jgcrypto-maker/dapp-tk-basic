// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { Test } from "forge-std/Test.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { SaleToken } from "../src/SaleToken.sol";
import { TokenSale } from "../src/TokenSale.sol";

/// @notice Shared fixture for the sale tests. Default launch case: 1,000,000 TK supply,
///         100 % as inventory, 0.01 POL/TK, 1,000 / 100,000 TK purchase limits.
abstract contract SaleFixture is Test {
    uint256 internal constant SUPPLY = 1_000_000e18;
    uint256 internal constant INVENTORY = 1_000_000e18;
    uint256 internal constant PRICE = 1e16; // 0.01 POL per token
    uint256 internal constant MIN = 1_000e18;
    uint256 internal constant MAX = 100_000e18;

    address internal owner = makeAddr("owner");
    address internal treasury = makeAddr("treasury");
    address internal alice = makeAddr("alice");
    address internal bob = makeAddr("bob");
    address internal sink = makeAddr("sink");

    TokenSale internal sale;
    SaleToken internal token;

    function _config() internal view returns (TokenSale.SaleConfig memory c) {
        c = TokenSale.SaleConfig({
            name: "Demo Token",
            symbol: "TK",
            totalSupply: SUPPLY,
            inventory: INVENTORY,
            treasury: treasury,
            pricePerTokenWei: PRICE,
            startTime: uint64(block.timestamp),
            endTime: uint64(block.timestamp + 30 days),
            minTokensPerPurchase: MIN,
            maxTokensPerWallet: MAX,
            owner: owner
        });
    }

    function _deploy(TokenSale.SaleConfig memory c) internal returns (TokenSale s) {
        s = new TokenSale(c);
    }

    function _buy(TokenSale s, address who, uint256 amount) internal returns (uint256 cost) {
        cost = s.quote(amount);
        vm.deal(who, cost);
        vm.prank(who);
        s.buy{ value: cost }(amount);
    }

    function setUp() public virtual {
        sale = _deploy(_config());
        token = sale.token();
    }
}

contract SaleTokenTest is SaleFixture {
    function testDeployMintsWholeSupplyAsInventory() public view {
        assertEq(token.totalSupply(), SUPPLY);
        assertEq(token.balanceOf(address(sale)), INVENTORY);
        assertEq(token.balanceOf(treasury), 0);
        assertEq(token.decimals(), 18);
        assertEq(sale.inventory(), INVENTORY);
        assertEq(sale.remainingTokens(), INVENTORY);
        assertEq(sale.owner(), owner);
        assertEq(sale.pricePerTokenWei(), PRICE);
    }

    function testDeployReservesTreasuryWhenInventoryIsLower() public {
        TokenSale.SaleConfig memory c = _config();
        c.inventory = 700_000e18;
        c.treasury = treasury;
        TokenSale split = _deploy(c);

        assertEq(split.token().balanceOf(address(split)), 700_000e18);
        assertEq(split.token().balanceOf(treasury), 300_000e18);
        assertEq(split.remainingTokens(), 700_000e18);
    }

    function testTokenHasNoMintOrAdmin() public view {
        // SaleToken only exposes the ERC-20 surface: supply cannot change after deployment.
        assertEq(token.totalSupply(), SUPPLY);
        assertEq(token.balanceOf(address(sale)) + token.balanceOf(treasury), SUPPLY);
    }

    function testTokenRevertsOnInvalidSupply() public {
        vm.expectRevert(SaleToken.InvalidSupply.selector);
        new SaleToken("X", "X", 10, address(this), 11, treasury);

        vm.expectRevert(SaleToken.InvalidSupply.selector);
        new SaleToken("X", "X", 10, address(this), 0, treasury);
    }

    function testTokenRevertsOnZeroAddresses() public {
        vm.expectRevert(SaleToken.ZeroAddress.selector);
        new SaleToken("X", "X", 10, address(0), 5, treasury);

        vm.expectRevert(SaleToken.ZeroAddress.selector);
        new SaleToken("X", "X", 10, address(this), 5, address(0));
    }
}

contract TokenSaleDeployTest is SaleFixture {
    function testDeployRevertsOnInvalidConfig() public {
        TokenSale.SaleConfig memory c = _config();
        c.pricePerTokenWei = 0;
        vm.expectRevert(TokenSale.InvalidConfig.selector);
        new TokenSale(c);

        c = _config();
        c.inventory = 0;
        vm.expectRevert(TokenSale.InvalidConfig.selector);
        new TokenSale(c);

        c = _config();
        c.inventory = SUPPLY + 1;
        vm.expectRevert(TokenSale.InvalidConfig.selector);
        new TokenSale(c);

        c = _config();
        c.minTokensPerPurchase = 0;
        vm.expectRevert(TokenSale.InvalidConfig.selector);
        new TokenSale(c);

        c = _config();
        c.minTokensPerPurchase = INVENTORY + 1;
        vm.expectRevert(TokenSale.InvalidConfig.selector);
        new TokenSale(c);

        c = _config();
        c.maxTokensPerWallet = MIN - 1;
        vm.expectRevert(TokenSale.InvalidConfig.selector);
        new TokenSale(c);

        c = _config();
        c.endTime = c.startTime;
        vm.expectRevert(TokenSale.InvalidConfig.selector);
        new TokenSale(c);

        c = _config();
        c.endTime = uint64(block.timestamp);
        vm.expectRevert(TokenSale.InvalidConfig.selector);
        new TokenSale(c);
    }

    function testDeployRevertsOnZeroTreasury() public {
        TokenSale.SaleConfig memory c = _config();
        c.treasury = address(0);
        vm.expectRevert(TokenSale.ZeroAddress.selector);
        new TokenSale(c);
    }

    function testDeployRevertsOnZeroOwner() public {
        TokenSale.SaleConfig memory c = _config();
        c.owner = address(0);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableInvalidOwner.selector, address(0)));
        new TokenSale(c);
    }
}

contract TokenSaleBuyTest is SaleFixture {
    function testBuyUpdatesAccounting() public {
        uint256 amount = MIN;
        uint256 cost = sale.quote(amount);
        assertEq(cost, 1e19); // 1,000 TK at 0.01 POL = 10 POL

        vm.deal(alice, cost);
        vm.prank(alice);
        sale.buy{ value: cost }(amount);

        assertEq(token.balanceOf(alice), amount);
        assertEq(sale.tokensPurchasedBy(alice), amount);
        assertEq(sale.weiPaidBy(alice), cost);
        assertEq(sale.totalTokensSold(), amount);
        assertEq(sale.totalRaisedWei(), cost);
        assertEq(sale.buyerCount(), 1);
        assertEq(sale.remainingTokens(), INVENTORY - amount);
        assertEq(address(sale).balance, cost);
    }

    function testSecondPurchaseDoesNotDuplicateBuyer() public {
        _buy(sale, alice, MIN);
        _buy(sale, alice, MIN);
        _buy(sale, bob, MIN);

        assertEq(sale.buyerCount(), 2);
        assertEq(sale.tokensPurchasedBy(alice), 2 * MIN);
        (address[] memory buyers,,) = sale.getBuyers(0, 10);
        assertEq(buyers.length, 2);
        assertEq(buyers[0], alice);
        assertEq(buyers[1], bob);
    }

    function testQuoteRoundsUp() public {
        TokenSale.SaleConfig memory c = _config();
        c.pricePerTokenWei = 1.5e18; // 1.5 wei per token
        TokenSale odd = _deploy(c);

        assertEq(odd.quote(1), 2); // 1.5 -> 2
        assertEq(odd.quote(3), 5); // 4.5 -> 5
        assertEq(odd.quote(2), 3); // 3 exact
        assertEq(odd.quote(0), 0);
    }

    function testGetBuyersPagination() public {
        for (uint256 i = 0; i < 5; i++) {
            _buy(sale, makeAddr(string.concat("buyer", vm.toString(i))), MIN);
        }
        (address[] memory buyers,,) = sale.getBuyers(3, 100);
        assertEq(buyers.length, 2);

        (buyers,,) = sale.getBuyers(10, 5);
        assertEq(buyers.length, 0);

        (buyers,,) = sale.getBuyers(0, 2);
        assertEq(buyers.length, 2);
    }

    function testGetBuyersCapsPageSize() public {
        for (uint256 i = 0; i < 101; i++) {
            _buy(sale, makeAddr(string.concat("b", vm.toString(i))), MIN);
        }
        (address[] memory buyers,,) = sale.getBuyers(0, 500);
        assertEq(buyers.length, sale.MAX_PAGE());
    }

    function testSaleStateSnapshot() public {
        _buy(sale, alice, 10 * MIN);
        TokenSale.SaleState memory s = sale.saleState();

        assertEq(s.token, address(token));
        assertEq(s.totalSupply, SUPPLY);
        assertEq(s.inventory, INVENTORY);
        assertEq(s.remainingTokens, INVENTORY - 10 * MIN);
        assertEq(s.totalTokensSold, 10 * MIN);
        assertEq(s.totalRaisedWei, 10 * MIN * PRICE / 1e18);
        assertEq(s.withdrawableWei, s.totalRaisedWei);
        assertEq(s.totalWithdrawnWei, 0);
        assertEq(s.totalSweptTokens, 0);
        assertEq(s.buyerCount, 1);
        assertFalse(s.paused);
        assertEq(s.owner, owner);
        assertEq(s.pricePerTokenWei, PRICE);
        assertEq(s.startTime, sale.startTime());
        assertEq(s.endTime, sale.endTime());
    }

    function testRevertWhenZeroAmount() public {
        vm.prank(alice);
        vm.expectRevert(TokenSale.ZeroAmount.selector);
        sale.buy(0);
    }

    function testRevertWhenBelowMinimum() public {
        vm.deal(alice, 10e18);
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(TokenSale.BelowMinimum.selector, MIN));
        sale.buy{ value: 1 }(MIN - 1);
    }

    function testRevertWhenIncorrectPayment() public {
        uint256 cost = sale.quote(MIN);
        vm.deal(alice, 100e18);

        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(TokenSale.IncorrectPayment.selector, cost, cost - 1));
        sale.buy{ value: cost - 1 }(MIN);

        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(TokenSale.IncorrectPayment.selector, cost, cost + 1));
        sale.buy{ value: cost + 1 }(MIN);

        assertEq(token.balanceOf(alice), 0);
        assertEq(address(sale).balance, 0);
    }

    function testRevertWhenAboveWalletCap() public {
        _buy(sale, alice, MAX);
        uint256 cost = sale.quote(MIN);
        vm.deal(alice, cost);
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(TokenSale.AboveWalletCap.selector, MAX));
        sale.buy{ value: cost }(MIN);
    }

    function testRevertWhenSoldOut() public {
        TokenSale.SaleConfig memory c = _config();
        c.inventory = 10e18;
        c.minTokensPerPurchase = 1e18;
        c.maxTokensPerWallet = 0;
        TokenSale small = _deploy(c);

        _buy(small, alice, 10e18);
        assertEq(small.remainingTokens(), 0);

        uint256 cost = small.quote(MIN);
        vm.deal(bob, cost);
        vm.prank(bob);
        vm.expectRevert(TokenSale.SoldOut.selector);
        small.buy{ value: cost }(MIN);
    }

    function testRevertWhenPaused() public {
        vm.prank(owner);
        sale.pause();

        uint256 cost = sale.quote(MIN);
        vm.deal(alice, cost);
        vm.prank(alice);
        vm.expectRevert(TokenSale.SalePaused.selector);
        sale.buy{ value: cost }(MIN);

        vm.prank(owner);
        sale.unpause();
        _buy(sale, alice, MIN);
        assertEq(token.balanceOf(alice), MIN);
    }

    function testRevertWhenNotStarted() public {
        TokenSale.SaleConfig memory c = _config();
        c.startTime = uint64(block.timestamp + 1 days);
        c.endTime = uint64(block.timestamp + 31 days);
        TokenSale later = _deploy(c);

        uint256 cost = later.quote(MIN);
        vm.deal(alice, cost);
        vm.prank(alice);
        vm.expectRevert(TokenSale.SaleNotStarted.selector);
        later.buy{ value: cost }(MIN);

        vm.warp(c.startTime);
        _buy(later, alice, MIN);
    }

    function testRevertWhenEnded() public {
        vm.warp(sale.endTime() + 1);
        uint256 cost = sale.quote(MIN);
        vm.deal(alice, cost);
        vm.prank(alice);
        vm.expectRevert(TokenSale.SaleEnded.selector);
        sale.buy{ value: cost }(MIN);
    }

    function testPlainEtherIsRejected() public {
        vm.deal(alice, 1 ether);
        vm.prank(alice);
        (bool ok,) = address(sale).call{ value: 1 ether }("");
        assertFalse(ok);

        vm.prank(alice);
        (ok,) = address(sale).call{ value: 1 ether }(hex"deadbeef");
        assertFalse(ok);
    }
}

contract TokenSaleAdminTest is SaleFixture {
    function testOnlyOwnerCanAdminister() public {
        bytes memory err =
            abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice);

        vm.startPrank(alice);
        vm.expectRevert(err);
        sale.pause();
        vm.expectRevert(err);
        sale.unpause();
        vm.expectRevert(err);
        sale.withdrawProceeds(payable(alice));
        vm.expectRevert(err);
        sale.sweepUnsold(alice);
        vm.expectRevert(err);
        sale.sweepForeignToken(token, alice);
        vm.stopPrank();
    }

    function testWithdrawProceeds() public {
        uint256 cost = _buy(sale, alice, 100 * MIN);

        vm.prank(owner);
        sale.withdrawProceeds(payable(sink));

        assertEq(sink.balance, cost);
        assertEq(address(sale).balance, 0);
        assertEq(sale.totalWithdrawnWei(), cost);
        assertEq(sale.totalRaisedWei(), cost); // raised is cumulative, it does not decrease
    }

    function testWithdrawRevertsOnZeroAddressAndFailedTransfer() public {
        _buy(sale, alice, MIN);

        vm.startPrank(owner);
        vm.expectRevert(TokenSale.ZeroAddress.selector);
        sale.withdrawProceeds(payable(address(0)));

        // The token contract does not accept POL: the call fails and reverts.
        vm.expectRevert(TokenSale.TransferFailed.selector);
        sale.withdrawProceeds(payable(address(token)));
        vm.stopPrank();
    }

    function testSweepUnsoldOnlyAfterEnd() public {
        _buy(sale, alice, 100 * MIN);

        vm.prank(owner);
        vm.expectRevert(TokenSale.SaleNotEnded.selector);
        sale.sweepUnsold(sink);

        vm.warp(sale.endTime() + 1);
        vm.prank(owner);
        sale.sweepUnsold(sink);

        assertEq(token.balanceOf(sink), INVENTORY - 100 * MIN);
        assertEq(sale.remainingTokens(), 0);
        assertEq(sale.totalSweptTokens(), INVENTORY - 100 * MIN);
        assertEq(token.balanceOf(alice), 100 * MIN);
    }

    function testSweepForeignToken() public {
        SaleToken other = new SaleToken("Other", "OTH", 1000e18, address(sale), 1000e18, treasury);
        assertEq(other.balanceOf(address(sale)), 1000e18);

        vm.startPrank(owner);
        vm.expectRevert(TokenSale.InvalidToken.selector);
        sale.sweepForeignToken(token, sink);

        sale.sweepForeignToken(other, sink);
        vm.stopPrank();

        assertEq(other.balanceOf(sink), 1000e18);
        assertEq(sale.remainingTokens(), INVENTORY);
    }

    function testOwnershipTransferIsTwoStep() public {
        vm.prank(owner);
        sale.transferOwnership(bob);
        assertEq(sale.owner(), owner);

        vm.prank(bob);
        sale.acceptOwnership();
        assertEq(sale.owner(), bob);
    }
}

contract TokenSaleFuzzTest is SaleFixture {
    function testFuzzBuyAccounting(uint256 amount) public {
        amount = bound(amount, MIN, MAX);
        uint256 cost = _buy(sale, alice, amount);

        // Rounded up: cost * 1e18 >= amount * price, and never more than one token unit above.
        assertGe(cost * 1e18, amount * PRICE);
        assertLt(cost * 1e18, amount * PRICE + 1e18);

        assertEq(token.balanceOf(alice), amount);
        assertEq(sale.totalTokensSold(), amount);
        assertEq(sale.totalRaisedWei(), cost);
        assertEq(token.balanceOf(address(sale)) + sale.totalTokensSold(), INVENTORY);
    }

    function testFuzzWrongPaymentAlwaysReverts(uint256 amount, uint256 sent) public {
        amount = bound(amount, MIN, MAX);
        uint256 cost = sale.quote(amount);
        sent = bound(sent, 0, cost * 2);
        vm.assume(sent != cost);

        vm.deal(alice, sent);
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(TokenSale.IncorrectPayment.selector, cost, sent));
        sale.buy{ value: sent }(amount);
    }

    function testFuzzWalletCapIsEnforced(uint256 first, uint256 second) public {
        first = bound(first, MIN, MAX);
        second = bound(second, MIN, MAX);
        _buy(sale, alice, first);

        uint256 cost = sale.quote(second);
        vm.deal(alice, cost);
        vm.prank(alice);
        if (first + second > MAX) {
            vm.expectRevert(abi.encodeWithSelector(TokenSale.AboveWalletCap.selector, MAX));
        }
        sale.buy{ value: cost }(second);
    }
}
