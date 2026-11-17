"use client";

import { useEffect, useState } from "react";
import { isAddress } from "viem";

import { erc20Abi, saleAbi, type SaleState } from "@/lib/abi";
import { createSaleClient } from "@/lib/chain";
import { explorerAddress, formatPol, formatToken, shortAddress } from "@/lib/format";
import { loadRuntime, type RuntimeConfig } from "@/lib/runtime";

type Position = {
  config: RuntimeConfig;
  address: `0x${string}`;
  symbol: string;
  decimals: number;
  balance: bigint;
  purchased: bigint;
  paid: bigint;
  pricePerTokenWei: bigint;
  inventory: bigint;
};

export default function WalletPage() {
  const [address, setAddress] = useState("");
  const [position, setPosition] = useState<Position | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  async function lookup(raw: string) {
    setBusy(true);
    setError(null);
    setPosition(null);
    try {
      if (!isAddress(raw)) {
        throw new Error("Dirección no válida: se espera 0x seguido de 40 caracteres hex.");
      }

      const { config, deployment } = await loadRuntime();
      const sale = deployment.sales[0];
      const client = createSaleClient(config.chainId, config.rpcUrl);

      const [state, balance, purchased, paid, symbol, decimals] = await Promise.all([
        client.readContract({ address: sale.sale, abi: saleAbi, functionName: "saleState" }),
        client.readContract({
          address: sale.token,
          abi: erc20Abi,
          functionName: "balanceOf",
          args: [raw],
        }),
        client.readContract({
          address: sale.sale,
          abi: saleAbi,
          functionName: "tokensPurchasedBy",
          args: [raw],
        }),
        client.readContract({
          address: sale.sale,
          abi: saleAbi,
          functionName: "weiPaidBy",
          args: [raw],
        }),
        client.readContract({ address: sale.token, abi: erc20Abi, functionName: "symbol" }),
        client.readContract({ address: sale.token, abi: erc20Abi, functionName: "decimals" }),
      ]);

      const saleState = state as unknown as SaleState;
      setPosition({
        config,
        address: raw,
        symbol,
        decimals,
        balance,
        purchased,
        paid,
        pricePerTokenWei: saleState.pricePerTokenWei,
        inventory: saleState.inventory,
      });
    } catch (cause) {
      setError(cause instanceof Error ? cause.message : String(cause));
    } finally {
      setBusy(false);
    }
  }

  useEffect(() => {
    const param = new URLSearchParams(window.location.search).get("address");
    if (param) {
      setAddress(param);
      void lookup(param);
    }
    // Lookup runs once for the address in the URL.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return (
    <main>
      <p className="eyebrow">Fase 3 · consulta</p>
      <h1>Posición de una wallet</h1>
      <p className="lede">
        Consulta de solo lectura. Teclear una dirección nunca autoriza ningún pago ni identifica a
        nadie.
      </p>

      <form
        className="form"
        onSubmit={(event) => {
          event.preventDefault();
          void lookup(address.trim());
        }}
      >
        <input
          type="search"
          value={address}
          onChange={(event) => setAddress(event.target.value)}
          placeholder="0x…"
          aria-label="Dirección de wallet"
          spellCheck={false}
        />
        <button type="submit" disabled={busy || address.trim().length === 0}>
          {busy ? "Consultando…" : "Consultar"}
        </button>
      </form>

      {error && <div className="alert">{error}</div>}

      {position && (
        <>
          <section className="grid">
            <div className="card">
              <span className="label">Comprado</span>
              <span className="value">{formatToken(position.purchased, position.decimals, 4)}</span>
              <span className="mono">{position.symbol}</span>
            </div>
            <div className="card">
              <span className="label">POL pagado</span>
              <span className="value">{formatPol(position.paid, 4)}</span>
              <span className="mono">acumulado en esta venta</span>
            </div>
            <div className="card">
              <span className="label">Saldo actual</span>
              <span className="value">{formatToken(position.balance, position.decimals, 4)}</span>
              <span className="mono">
                {position.purchased === position.balance
                  ? "sin transferencias"
                  : "incluye transferencias externas"}
              </span>
            </div>
            <div className="card">
              <span className="label">Valor al precio actual</span>
              <span className="value">
                {formatPol((position.pricePerTokenWei * position.balance) / 10n ** 18n, 4)} POL
              </span>
              <span className="mono">informativo, no es una garantía</span>
            </div>
          </section>

          <h2>Detalle</h2>
          <table>
            <tbody>
              <tr>
                <td className="label">Wallet</td>
                <td className="mono">{position.address}</td>
                <td className="right">
                  <a
                    href={explorerAddress(position.config.explorerUrl, position.address)}
                    target="_blank"
                    rel="noreferrer"
                  >
                    explorador
                  </a>
                </td>
              </tr>
              <tr>
                <td className="label">Inventario</td>
                <td className="mono">{formatToken(position.inventory, position.decimals)}</td>
                <td className="right mono">total de la venta</td>
              </tr>
              <tr>
                <td className="label">Estado</td>
                <td colSpan={2}>
                  {position.purchased === 0n
                    ? "Esta wallet no ha comprado en esta venta."
                    : `Ha comprado ${formatToken(position.purchased, position.decimals, 4)} ${position.symbol}.`}
                </td>
              </tr>
            </tbody>
          </table>
        </>
      )}

      <footer>
        <div className="row">
          <a href="/">← Volver al dashboard</a>
          <span className="spacer" />
          {position && <span className="mono">{shortAddress(position.address, 6)}</span>}
        </div>
      </footer>
    </main>
  );
}
