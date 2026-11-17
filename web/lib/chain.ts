import { createPublicClient, http, type Chain, type PublicClient } from "viem";
import { hardhat, polygon, polygonAmoy } from "viem/chains";

const KNOWN_CHAINS: Record<number, Chain> = {
  137: polygon,
  80002: polygonAmoy,
  31337: hardhat,
};

function resolveChain(chainId: number, rpcUrl: string): Chain {
  const known = KNOWN_CHAINS[chainId];
  if (known) return known;
  return {
    id: chainId,
    name: `chain-${chainId}`,
    nativeCurrency: { name: "POL", symbol: "POL", decimals: 18 },
    rpcUrls: { default: { http: [rpcUrl] } },
  };
}

export function createSaleClient(chainId: number, rpcUrl: string): PublicClient {
  return createPublicClient({
    chain: resolveChain(chainId, rpcUrl),
    transport: http(rpcUrl),
  });
}
