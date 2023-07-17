import { SetupNetworkResult } from "./setupNetwork";

export type SystemCalls = ReturnType<typeof createSystemCalls>;

export function createSystemCalls({ execute, syncWorker }: SetupNetworkResult) {
  const initialize = async () => {
    const tx = await execute("initialize", []);
    // await awaitStreamValue(txReduced$, (txHash) => txHash === tx.transaction_hash);
    syncWorker.sync(tx.transaction_hash);
  };

  return {
    initialize,
  };
}
