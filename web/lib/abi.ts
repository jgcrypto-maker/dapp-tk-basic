import { erc20Abi } from "viem";

export { erc20Abi };

/** Minimal TokenSale ABI needed by the read-only dashboard. */
export const saleAbi = [
  {
    type: "function",
    name: "saleState",
    stateMutability: "view",
    inputs: [],
    outputs: [
      {
        type: "tuple",
        components: [
          { name: "token", type: "address" },
          { name: "totalSupply", type: "uint256" },
          { name: "inventory", type: "uint256" },
          { name: "remainingTokens", type: "uint256" },
          { name: "totalTokensSold", type: "uint256" },
          { name: "totalRaisedWei", type: "uint256" },
          { name: "withdrawableWei", type: "uint256" },
          { name: "totalWithdrawnWei", type: "uint256" },
          { name: "totalSweptTokens", type: "uint256" },
          { name: "buyerCount", type: "uint256" },
          { name: "pricePerTokenWei", type: "uint256" },
          { name: "startTime", type: "uint64" },
          { name: "endTime", type: "uint64" },
          { name: "paused", type: "bool" },
          { name: "owner", type: "address" },
        ],
      },
    ],
  },
  {
    type: "function",
    name: "quote",
    stateMutability: "view",
    inputs: [{ name: "tokenAmount", type: "uint256" }],
    outputs: [{ name: "", type: "uint256" }],
  },
  {
    type: "function",
    name: "tokensPurchasedBy",
    stateMutability: "view",
    inputs: [{ name: "buyer", type: "address" }],
    outputs: [{ name: "", type: "uint256" }],
  },
  {
    type: "function",
    name: "weiPaidBy",
    stateMutability: "view",
    inputs: [{ name: "buyer", type: "address" }],
    outputs: [{ name: "", type: "uint256" }],
  },
  {
    type: "function",
    name: "getBuyers",
    stateMutability: "view",
    inputs: [
      { name: "offset", type: "uint256" },
      { name: "limit", type: "uint256" },
    ],
    outputs: [
      { name: "buyers", type: "address[]" },
      { name: "tokenAmounts", type: "uint256[]" },
      { name: "paidWei", type: "uint256[]" },
    ],
  },
] as const;

/** `saleState()` decoded by viem as an object (tuple components are named). */
export type SaleState = {
  token: `0x${string}`;
  totalSupply: bigint;
  inventory: bigint;
  remainingTokens: bigint;
  totalTokensSold: bigint;
  totalRaisedWei: bigint;
  withdrawableWei: bigint;
  totalWithdrawnWei: bigint;
  totalSweptTokens: bigint;
  buyerCount: bigint;
  pricePerTokenWei: bigint;
  startTime: bigint;
  endTime: bigint;
  paused: boolean;
  owner: `0x${string}`;
};
