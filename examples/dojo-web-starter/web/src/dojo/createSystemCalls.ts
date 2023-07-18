import { SetupNetworkResult, WORLD_ADDRESS } from "./setupNetwork";
import {
  BaseEventData,
  parseEvent,
  parseEvents,
  RyoEvents,
  CreateEventData,
} from "../utils/event";

export type SystemCalls = ReturnType<typeof createSystemCalls>;

export function createSystemCalls({
  provider,
  execute,
  syncWorker,
  signer,
}: SetupNetworkResult) {
  const initialize = async () => {
    const tx = await execute("initialize", []);
    syncWorker.sync(tx.transaction_hash);
  };

  const tick = async () => {
    const tx = await execute("tick", []);
    syncWorker.sync(tx.transaction_hash);
  };

  const listenRPC = async (): Promise<CreateEventData[]> => {
    const lastBlock = await provider.provider.getBlock("latest");

    let eventsList = await provider.provider.getEvents({
      address: WORLD_ADDRESS,
      from_block: { block_number: lastBlock.block_number - 2 },
      to_block: { block_number: lastBlock.block_number },
      chunk_size: 400,
    });

    const filteredGameBlockEvents: CreateEventData[] = parseEvents(
      eventsList["events"],
      RyoEvents.GameBlock
    );

    return filteredGameBlockEvents;
  };

  return {
    initialize,
    tick,
    listenRPC,
  };
}
