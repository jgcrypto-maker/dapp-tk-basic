"use client";

import { useEffect, useState } from "react";

import { erc20Abi, saleAbi, type SaleState } from "@/lib/abi";
import { createSaleClient } from "@/lib/chain";
import {
  countdown,
  explorerAddress,
  formatPol,
  formatToken,
  percent,
  saleStatus,
  shortAddress,
} from "@/lib/format";
import { loadRuntime, type DeploymentSale, type RuntimeConfig } from "@/lib/runtime";

type Buyer = { address: `0x${string}`; tokens: bigint; paid: bigint };

type Loaded = {
  config: RuntimeConfig;
  sale: DeploymentSale;
  state: SaleState;
  name: string;
  symbol: string;
  decimals: number;
  buyers: Buyer[];
};

export default function HomePage() {
  const [data, setData] = useState<Loaded | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [now, setNow] = useState(() => Math.floor(Date.now() / 1000));

  useEffect(() => {
    let cancelled = false;
    const timer = window.setInterval(() => setNow(Math.floor(Date.now() / 1000)), 30_000);

    (async () => {
      try {
        const { config, deployment } = await loadRuntime();
        if (deployment.chainId !== config.chainId) {
          throw new Error(
            `deployment.json es de chainId ${deployment.chainId} y config.json de ${config.chainId}`,
          );
        }

        const sale = deployment.sales[0];
        const client = createSaleClient(config.chainId, config.rpcUrl);

        const [state, name, symbol, decimals, rows] = await Promise.all([
          client.readContract({ address: sale.sale, abi: saleAbi, functionName: "saleState" }),
          client.readContract({ address: sale.token, abi: erc20Abi, functionName: "name" }),
          client.readContract({ address: sale.token, abi: erc20Abi, functionName: "symbol" }),
          client.readContract({ address: sale.token, abi: erc20Abi, functionName: "decimals" }),
          client.readContract({
            address: sale.sale,
            abi: saleAbi,
            functionName: "getBuyers",
            args: [0n, 100n],
          }),
        ]);

        const [addresses, amounts, paid] = rows;
        const buyers: Buyer[] = addresses.map((address, index) => ({
          address,
          tokens: amounts[index],
          paid: paid[index],
        }));

        if (!cancelled) {
          setData({
            config,
            sale,
            state: state as unknown as SaleState,
            name,
            symbol,
            decimals,
            buyers,
          });
        }
      } catch (cause) {
        if (!cancelled) {
          setError(cause instanceof Error ? cause.message : String(cause));
        }
      }
    })();

    return () => {
      cancelled = true;
      window.clearInterval(timer);
    };
  }, []);

  if (error) {
    return (
      <main>
        <p className="eyebrow">Fase 3 · dashboard</p>
        <h1>No se pudo cargar el estado</h1>
        <div className="alert">{error}</div>
        <p className="mono">
          Comprueba que Anvil está en marcha y que existe <code>/deployment.json</code> (ejecuta{" "}
          <code>make deploy-local</code>).
        </p>
      </main>
    );
  }

  if (!data) {
    return (
      <main>
        <p className="eyebrow">Fase 3 · dashboard</p>
        <h1>Cargando estado on-chain…</h1>
        <p className="lede">Leyendo configuración y contrato por RPC.</p>
      </main>
    );
  }

  const { config, sale, state, name, symbol, decimals, buyers } = data;
  const {
    token,
    totalSupply,
    inventory,
    remainingTokens,
    totalTokensSold,
    totalRaisedWei,
    withdrawableWei,
    buyerCount,
    pricePerTokenWei,
    startTime,
    endTime,
    paused,
    owner,
  } = state;

  const status = saleStatus({ paused, startTime, endTime, remainingTokens, now });
  const soldPercent = percent(totalTokensSold, inventory);
  const progress = inventory === 0n ? 0 : Number((totalTokensSold * 10_000n) / inventory) / 100;
  const fdvWei = (pricePerTokenWei * totalSupply) / 10n ** 18n;
  const soldValueWei = (pricePerTokenWei * totalTokensSold) / 10n ** 18n;

  return (
    <main>
      <p className="eyebrow">Fase 3 · dashboard</p>
      <div className="row">
        <h1 style={{ marginBottom: 0 }}>
          {name} <span className="mono">({symbol})</span>
        </h1>
        <span className="spacer" />
        <span className={`badge ${status.tone}`}>{status.label}</span>
      </div>
      <p className="lede">
        Venta primaria a precio fijo en POL. Todas las métricas se leen del contrato; nada se
        calcula en el servidor. Entorno <strong>{config.env}</strong>, chainId{" "}
        <strong>{config.chainId}</strong>.
      </p>

      <section className="grid">
        <div className="card">
          <span className="label">Precio</span>
          <span className="value">{formatPol(pricePerTokenWei, 6)} POL</span>
          <span className="mono">por 1 {symbol}</span>
        </div>
        <div className="card">
          <span className="label">Vendido</span>
          <span className="value">{formatToken(totalTokensSold, decimals)}</span>
          <span className="mono">{soldPercent} del inventario</span>
        </div>
        <div className="card">
          <span className="label">Restante</span>
          <span className="value">{formatToken(remainingTokens, decimals)}</span>
          <span className="mono">de {formatToken(inventory, decimals)}</span>
        </div>
        <div className="card">
          <span className="label">Recaudado</span>
          <span className="value">{formatPol(totalRaisedWei, 4)} POL</span>
          <span className="mono">retirable {formatPol(withdrawableWei, 4)} POL</span>
        </div>
        <div className="card">
          <span className="label">Compradores</span>
          <span className="value">{buyerCount.toString()}</span>
          <span className="mono">wallets únicas</span>
        </div>
        <div className="card">
          <span className="label">Cierre</span>
          <span className="value">{countdown(endTime, now)}</span>
          <span className="mono">{new Date(Number(endTime) * 1000).toLocaleString("es-ES")}</span>
        </div>
        <div className="card">
          <span className="label">FDV</span>
          <span className="value">{formatPol(fdvWei, 2)} POL</span>
          <span className="mono">valor vendido {formatPol(soldValueWei, 2)} POL</span>
        </div>
        <div className="card">
          <span className="label">Suministro</span>
          <span className="value">{formatToken(totalSupply, decimals)}</span>
          <span className="mono">fijo, sin mint</span>
        </div>
      </section>

      <div className="bar" aria-hidden>
        <span style={{ width: `${Math.min(100, Math.max(0, progress))}%` }} />
      </div>

      <h2>Contratos</h2>
      <table>
        <tbody>
          <tr>
            <td className="label">Venta</td>
            <td className="mono">{sale.sale}</td>
            <td className="right">
              <a href={explorerAddress(config.explorerUrl, sale.sale)} target="_blank" rel="noreferrer">
                explorador
              </a>
            </td>
          </tr>
          <tr>
            <td className="label">Token</td>
            <td className="mono">{token}</td>
            <td className="right">
              <a href={explorerAddress(config.explorerUrl, token)} target="_blank" rel="noreferrer">
                explorador
              </a>
            </td>
          </tr>
          <tr>
            <td className="label">Owner</td>
            <td className="mono">{owner}</td>
            <td className="right mono">{shortAddress(owner)}</td>
          </tr>
        </tbody>
      </table>

      <h2>Compradores (primeros {buyers.length})</h2>
      {buyers.length === 0 ? (
        <p className="lede">Todavía no hay compras.</p>
      ) : (
        <table>
          <thead>
            <tr>
              <th>Wallet</th>
              <th className="right">Tokens</th>
              <th className="right">POL pagado</th>
              <th className="right">Consulta</th>
            </tr>
          </thead>
          <tbody>
            {buyers.map((buyer) => (
              <tr key={buyer.address}>
                <td className="mono">{shortAddress(buyer.address)}</td>
                <td className="right">{formatToken(buyer.tokens, decimals)}</td>
                <td className="right">{formatPol(buyer.paid, 4)}</td>
                <td className="right">
                  <a href={`/wallet/?address=${buyer.address}`}>ver posición</a>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}

      <footer>
        <div className="row">
          <a href="/wallet/">Consultar una wallet</a>
          <span className="spacer" />
          <span className="mono">
            {sale.sale} · deploy block {sale.deployBlock}
          </span>
        </div>
      </footer>
    </main>
  );
}
