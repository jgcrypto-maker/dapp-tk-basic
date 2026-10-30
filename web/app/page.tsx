const chainId = process.env.NEXT_PUBLIC_CHAIN_ID ?? "31337";
const chainName =
  chainId === "137" ? "Polygon PoS" : chainId === "80002" ? "Polygon Amoy" : "Anvil (local)";

const phases = [
  { id: "0", label: "Arquitectura", state: "done" },
  { id: "1", label: "Toolchain Docker", state: "current" },
  { id: "2", label: "Contratos", state: "next" },
  { id: "3", label: "Dashboard", state: "next" },
  { id: "4", label: "Compra E2E", state: "next" },
] as const;

export default function HomePage() {
  return (
    <main>
      <p style={{ color: "var(--muted)", margin: 0, fontSize: 14, letterSpacing: "0.08em" }}>
        FASE 1 · TOOLCHAIN
      </p>
      <h1 style={{ fontSize: "clamp(2rem, 6vw, 3.25rem)", margin: "0.4rem 0 0.75rem" }}>
        dapp-tk-basic
      </h1>
      <p style={{ color: "var(--muted)", margin: 0, maxWidth: 620 }}>
        Prototipo de venta de un token ERC-20 a precio fijo en POL sobre Polygon. Esta página es el
        “hola mundo” del toolchain: Next.js, Foundry y Anvil corriendo en contenedores.
      </p>

      <section
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(200px, 1fr))",
          gap: 12,
          marginTop: 32,
        }}
      >
        <div style={cardStyle}>
          <span style={labelStyle}>Red configurada</span>
          <strong style={{ fontSize: 20 }}>{chainName}</strong>
          <span style={monoStyle}>chainId {chainId}</span>
        </div>
        <div style={cardStyle}>
          <span style={labelStyle}>Healthcheck</span>
          <strong style={{ fontSize: 20, color: "var(--ok)" }}>API operativa</strong>
          <a href="/api/health" style={monoStyle}>
            /api/health
          </a>
        </div>
      </section>

      <section style={{ marginTop: 36 }}>
        <h2 style={{ fontSize: 16, textTransform: "uppercase", letterSpacing: "0.06em" }}>
          Plan por fases
        </h2>
        <ul style={{ listStyle: "none", padding: 0, margin: "12px 0 0", display: "grid", gap: 8 }}>
          {phases.map((phase) => (
            <li key={phase.id} style={rowStyle}>
              <span style={{ ...badgeStyle, ...badgeState[phase.state] }}>{phase.id}</span>
              <span style={{ opacity: phase.state === "next" ? 0.6 : 1 }}>{phase.label}</span>
              <span style={{ marginLeft: "auto", ...monoStyle, fontSize: 12 }}>
                {phase.state === "done" ? "cerrada" : phase.state === "current" ? "en curso" : "pendiente"}
              </span>
            </li>
          ))}
        </ul>
      </section>

      <p style={{ ...monoStyle, marginTop: 40 }}>
        Documentación: docs/ARCHITECTURE.md · docs/ENVIRONMENT.md
      </p>
    </main>
  );
}

const cardStyle: React.CSSProperties = {
  display: "grid",
  gap: 4,
  padding: "16px 18px",
  background: "var(--panel)",
  border: "1px solid var(--border)",
  borderRadius: 12,
};

const labelStyle: React.CSSProperties = {
  color: "var(--muted)",
  fontSize: 12,
  textTransform: "uppercase",
  letterSpacing: "0.06em",
};

const monoStyle: React.CSSProperties = {
  fontFamily: "ui-monospace, SFMono-Regular, Menlo, monospace",
  fontSize: 13,
  color: "var(--muted)",
};

const rowStyle: React.CSSProperties = {
  display: "flex",
  alignItems: "center",
  gap: 12,
  padding: "10px 14px",
  background: "var(--panel)",
  border: "1px solid var(--border)",
  borderRadius: 10,
};

const badgeStyle: React.CSSProperties = {
  display: "inline-flex",
  alignItems: "center",
  justifyContent: "center",
  width: 26,
  height: 26,
  borderRadius: "50%",
  fontSize: 13,
  fontWeight: 600,
  background: "#1b2431",
  color: "var(--text)",
};

const badgeState: Record<(typeof phases)[number]["state"], React.CSSProperties> = {
  done: { background: "var(--ok)", color: "#04120a" },
  current: { background: "var(--accent)", color: "#fff" },
  next: { background: "#1b2431", color: "var(--muted)" },
};
