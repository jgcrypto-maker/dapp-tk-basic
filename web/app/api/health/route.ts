import { NextResponse } from "next/server";

export const dynamic = "force-dynamic";

/** Liveness probe used by Docker and the edge proxy. */
export function GET() {
  return NextResponse.json({
    status: "ok",
    service: "dapp-tk-web",
    chainId: Number(process.env.NEXT_PUBLIC_CHAIN_ID ?? 31337),
  });
}
