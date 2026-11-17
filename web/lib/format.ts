import { formatUnits } from "viem";

export function shortAddress(address: string, size = 4): string {
  return `${address.slice(0, 2 + size)}…${address.slice(-size)}`;
}

export function formatToken(amount: bigint, decimals = 18, maximumFractionDigits = 2): string {
  const value = Number(formatUnits(amount, decimals));
  return new Intl.NumberFormat("es-ES", { maximumFractionDigits }).format(value);
}

export function formatPol(wei: bigint, maximumFractionDigits = 4): string {
  const value = Number(formatUnits(wei, 18));
  return new Intl.NumberFormat("es-ES", { maximumFractionDigits }).format(value);
}

export function percent(part: bigint, total: bigint): string {
  if (total === 0n) return "0 %";
  const ratio = Number((part * 10_000n) / total) / 100;
  return `${new Intl.NumberFormat("es-ES", { maximumFractionDigits: 1 }).format(ratio)} %`;
}

export function saleStatus(state: {
  paused: boolean;
  startTime: bigint;
  endTime: bigint;
  remainingTokens: bigint;
  now: number;
}): { label: string; tone: "ok" | "warn" | "muted" } {
  if (state.paused) return { label: "Pausada", tone: "warn" };
  if (BigInt(state.now) < state.startTime) return { label: "Programada", tone: "muted" };
  if (state.remainingTokens === 0n) return { label: "Agotada", tone: "ok" };
  if (BigInt(state.now) > state.endTime) return { label: "Finalizada", tone: "muted" };
  return { label: "Activa", tone: "ok" };
}

export function countdown(endTime: bigint, now: number): string {
  const seconds = Number(endTime) - now;
  if (seconds <= 0) return "cerrada";
  const days = Math.floor(seconds / 86_400);
  const hours = Math.floor((seconds % 86_400) / 3_600);
  if (days > 0) return `${days} d ${hours} h`;
  const minutes = Math.floor((seconds % 3_600) / 60);
  return `${hours} h ${minutes} min`;
}

export function explorerAddress(explorerUrl: string, address: string): string {
  if (!explorerUrl) return address;
  return `${explorerUrl.replace(/\/$/, "")}/address/${address}`;
}
