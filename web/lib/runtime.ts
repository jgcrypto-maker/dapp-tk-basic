export type RuntimeConfig = {
  env: string;
  chainId: number;
  rpcUrl: string;
  explorerUrl: string;
  polUsdRate: number;
};

export type DeploymentSale = {
  id: number;
  sale: `0x${string}`;
  token: `0x${string}`;
  owner: `0x${string}`;
  deployBlock: number;
};

export type Deployment = {
  chainId: number;
  sales: DeploymentSale[];
};

async function fetchJson<T>(path: string): Promise<T> {
  const response = await fetch(path, { cache: "no-store" });
  if (!response.ok) {
    throw new Error(`${path} respondió ${response.status}`);
  }
  return (await response.json()) as T;
}

export async function loadRuntime(): Promise<{ config: RuntimeConfig; deployment: Deployment }> {
  const [config, deployment] = await Promise.all([
    fetchJson<RuntimeConfig>("/config.json"),
    fetchJson<Deployment>("/deployment.json"),
  ]);

  if (!config.chainId || !config.rpcUrl) {
    throw new Error("config.json incompleto: faltan chainId o rpcUrl");
  }
  if (!Array.isArray(deployment.sales) || deployment.sales.length === 0) {
    throw new Error("deployment.json no contiene ventas");
  }

  return { config, deployment };
}
