import { SetupNetworkResult } from "./setupNetwork";
import { BaseEventData, parseEvent, RyoEvents } from "../utils/event";

export type SystemCalls = ReturnType<typeof createSystemCalls>;

export function createSystemCalls({
  provider,
  execute,
  syncWorker,
}: SetupNetworkResult) {
  const initialize = async () => {
    const tx = await execute("initialize", []);
    const receipt = await provider.provider.getTransactionReceipt(
      tx.transaction_hash
    );
    console.log(parseEvent(receipt, RyoEvents.GameBlock));
    syncWorker.sync(tx.transaction_hash);
  };

  const tick = async () => {
    const tx = await execute("tick", []);
    const receipt = await provider.provider.getTransactionReceipt(
      tx.transaction_hash
    );
    console.log(parseEvent(receipt, RyoEvents.GameBlock));
    syncWorker.sync(tx.transaction_hash);
    console.log(provider.provider.getEvents);
  };

  return {
    initialize,
    tick,
  };
}
