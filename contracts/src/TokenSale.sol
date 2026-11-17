// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Ownable2Step } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { Pausable } from "@openzeppelin/contracts/utils/Pausable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
import { SaleToken } from "./SaleToken.sol";

/// @title TokenSale
/// @notice Primary sale at a fixed, immutable POL price. Creates its own `SaleToken`, keeps the
///         inventory and the full accounting on-chain (ADR-02, ADR-03, ADR-04).
/// @dev Price, window and limits are immutable: redeploying is the only way to change them.
contract TokenSale is Ownable2Step, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    struct SaleConfig {
        string name;
        string symbol;
        uint256 totalSupply; // minimum units (18 decimals)
        uint256 inventory; // tokens for sale, <= totalSupply
        address treasury; // receives totalSupply - inventory
        uint256 pricePerTokenWei; // wei of POL per whole token
        uint64 startTime;
        uint64 endTime;
        uint256 minTokensPerPurchase;
        uint256 maxTokensPerWallet; // 0 = no cap
        address owner;
    }

    struct SaleState {
        address token;
        uint256 totalSupply;
        uint256 inventory;
        uint256 remainingTokens;
        uint256 totalTokensSold;
        uint256 totalRaisedWei;
        uint256 withdrawableWei;
        uint256 totalWithdrawnWei;
        uint256 totalSweptTokens;
        uint256 buyerCount;
        uint256 pricePerTokenWei;
        uint64 startTime;
        uint64 endTime;
        bool paused;
        address owner;
    }

    uint256 private constant ONE_TOKEN = 1e18;
    uint256 public constant MAX_PAGE = 100;

    SaleToken public immutable token;
    uint256 public immutable inventory;
    uint256 public immutable pricePerTokenWei;
    uint64 public immutable startTime;
    uint64 public immutable endTime;
    uint256 public immutable minTokensPerPurchase;
    uint256 public immutable maxTokensPerWallet;

    uint256 public totalTokensSold;
    uint256 public totalRaisedWei;
    uint256 public totalWithdrawnWei;
    uint256 public totalSweptTokens;

    mapping(address => uint256) public tokensPurchasedBy;
    mapping(address => uint256) public weiPaidBy;
    address[] private _buyers;

    event TokensPurchased(address indexed buyer, uint256 tokenAmount, uint256 paidWei);
    event ProceedsWithdrawn(address indexed to, uint256 amountWei);
    event UnsoldSwept(address indexed to, uint256 tokenAmount);
    event ForeignTokenSwept(address indexed token, address indexed to, uint256 amount);

    error SalePaused();
    error SaleNotStarted();
    error SaleEnded();
    error SaleNotEnded();
    error ZeroAmount();
    error BelowMinimum(uint256 minimum);
    error SoldOut();
    error AboveWalletCap(uint256 cap);
    error IncorrectPayment(uint256 expectedWei, uint256 receivedWei);
    error InvalidConfig();
    error InvalidToken();
    error TransferFailed();
    error ZeroAddress();

    constructor(SaleConfig memory c) Ownable(c.owner) {
        if (c.treasury == address(0)) revert ZeroAddress();
        if (c.pricePerTokenWei == 0 || c.inventory == 0 || c.inventory > c.totalSupply) {
            revert InvalidConfig();
        }
        if (c.minTokensPerPurchase == 0 || c.minTokensPerPurchase > c.inventory) {
            revert InvalidConfig();
        }
        if (c.maxTokensPerWallet != 0 && c.maxTokensPerWallet < c.minTokensPerPurchase) {
            revert InvalidConfig();
        }
        if (c.startTime >= c.endTime || c.endTime <= block.timestamp) revert InvalidConfig();

        token =
            new SaleToken(c.name, c.symbol, c.totalSupply, address(this), c.inventory, c.treasury);
        inventory = c.inventory;
        pricePerTokenWei = c.pricePerTokenWei;
        startTime = c.startTime;
        endTime = c.endTime;
        minTokensPerPurchase = c.minTokensPerPurchase;
        maxTokensPerWallet = c.maxTokensPerWallet;
    }

    // ---------------------------------------------------------------- Investor

    /// @notice Buys exactly `tokenAmount` (minimum units) paying `quote(tokenAmount)` in POL.
    /// @dev Checks-Effects-Interactions; the exact payment is required, overpayment reverts.
    function buy(uint256 tokenAmount) external payable nonReentrant {
        if (paused()) revert SalePaused();
        if (block.timestamp < startTime) revert SaleNotStarted();
        if (block.timestamp > endTime) revert SaleEnded();
        if (tokenAmount == 0) revert ZeroAmount();
        if (tokenAmount < minTokensPerPurchase) revert BelowMinimum(minTokensPerPurchase);
        if (tokenAmount > remainingTokens()) revert SoldOut();

        uint256 previous = tokensPurchasedBy[msg.sender];
        if (maxTokensPerWallet != 0 && previous + tokenAmount > maxTokensPerWallet) {
            revert AboveWalletCap(maxTokensPerWallet);
        }

        uint256 cost = quote(tokenAmount);
        if (msg.value != cost) revert IncorrectPayment(cost, msg.value);

        if (previous == 0) _buyers.push(msg.sender);
        tokensPurchasedBy[msg.sender] = previous + tokenAmount;
        weiPaidBy[msg.sender] += cost;
        totalTokensSold += tokenAmount;
        totalRaisedWei += cost;

        IERC20(address(token)).safeTransfer(msg.sender, tokenAmount);

        emit TokensPurchased(msg.sender, tokenAmount, cost);
    }

    // ---------------------------------------------------------------- Reads

    /// @notice Cost in wei of `tokenAmount`, rounded up.
    function quote(uint256 tokenAmount) public view returns (uint256) {
        return Math.mulDiv(tokenAmount, pricePerTokenWei, ONE_TOKEN, Math.Rounding.Ceil);
    }

    function remainingTokens() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function buyerCount() external view returns (uint256) {
        return _buyers.length;
    }

    function saleState() external view returns (SaleState memory) {
        return SaleState({
            token: address(token),
            totalSupply: token.totalSupply(),
            inventory: inventory,
            remainingTokens: remainingTokens(),
            totalTokensSold: totalTokensSold,
            totalRaisedWei: totalRaisedWei,
            withdrawableWei: address(this).balance,
            totalWithdrawnWei: totalWithdrawnWei,
            totalSweptTokens: totalSweptTokens,
            buyerCount: _buyers.length,
            pricePerTokenWei: pricePerTokenWei,
            startTime: startTime,
            endTime: endTime,
            paused: paused(),
            owner: owner()
        });
    }

    /// @notice Paginated buyer list. `limit` is capped at `MAX_PAGE` to bound gas.
    function getBuyers(uint256 offset, uint256 limit)
        external
        view
        returns (address[] memory buyers, uint256[] memory tokenAmounts, uint256[] memory paidWei)
    {
        uint256 total = _buyers.length;
        if (limit > MAX_PAGE) limit = MAX_PAGE;
        uint256 n = offset >= total ? 0 : Math.min(limit, total - offset);

        buyers = new address[](n);
        tokenAmounts = new uint256[](n);
        paidWei = new uint256[](n);
        for (uint256 i = 0; i < n; i++) {
            address buyer = _buyers[offset + i];
            buyers[i] = buyer;
            tokenAmounts[i] = tokensPurchasedBy[buyer];
            paidWei[i] = weiPaidBy[buyer];
        }
    }

    // ---------------------------------------------------------------- Owner

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    /// @notice Sends the whole POL balance of the sale to `to`.
    function withdrawProceeds(address payable to) external onlyOwner nonReentrant {
        if (to == address(0)) revert ZeroAddress();
        uint256 amount = address(this).balance;
        totalWithdrawnWei += amount;
        (bool ok,) = to.call{ value: amount }("");
        if (!ok) revert TransferFailed();
        emit ProceedsWithdrawn(to, amount);
    }

    /// @notice After the sale closes, sends the unsold tokens to `to`.
    function sweepUnsold(address to) external onlyOwner {
        if (block.timestamp <= endTime) revert SaleNotEnded();
        if (to == address(0)) revert ZeroAddress();
        uint256 amount = remainingTokens();
        totalSweptTokens += amount;
        IERC20(address(token)).safeTransfer(to, amount);
        emit UnsoldSwept(to, amount);
    }

    /// @notice Reclaims ERC-20 tokens sent to the sale by mistake.
    function sweepForeignToken(IERC20 other, address to) external onlyOwner {
        if (address(other) == address(token)) revert InvalidToken();
        if (to == address(0)) revert ZeroAddress();
        uint256 amount = other.balanceOf(address(this));
        other.safeTransfer(to, amount);
        emit ForeignTokenSwept(address(other), to, amount);
    }
}
