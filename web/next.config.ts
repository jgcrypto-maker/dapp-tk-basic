import type { NextConfig } from "next";

// Static export: one image per release, configuration injected at runtime
// through /config.json and /deployment.json (ADR-15).
const nextConfig: NextConfig = {
  output: "export",
  trailingSlash: true,
  images: { unoptimized: true },
  reactStrictMode: true,
  poweredByHeader: false,
};

export default nextConfig;
