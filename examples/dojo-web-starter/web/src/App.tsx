import "./App.css";
import { useDojo } from "./DojoContext";
import { useComponentValue } from "@dojoengine/react";
import { Utils } from "@dojoengine/core";
import { RyoEvents, CreateEventData } from "./utils/event";

function App() {
  const {
    systemCalls: { initialize, tick, listenRPC },
    components: { GameStats },
  } = useDojo();

  const entityId = BigInt(import.meta.env.VITE_ENTITY_ID);
  const gamestats = useComponentValue(
    GameStats,
    Utils.getEntityIdFromKeys([entityId])
  );

  let isRunning = false; // A flag to keep track of whether the event watcher is running.

  async function startEventWatcher(): Promise<void> {
    if (isRunning) {
      console.log("Event watcher is already running.");
      return;
    }

    isRunning = true;

    const arrayMap = new Map<number, CreateEventData[]>();

    while (isRunning) {
      try {
        const newEvent = await listenRPC();

        for (const obj of newEvent) {
          const { blockNumber } = obj;
          if (!arrayMap.has(blockNumber)) {
            arrayMap.set(blockNumber, []);
            console.log("New event recorded:", obj);
          }
          arrayMap.get(blockNumber)?.push(obj);
        }
      } catch (error) {
        console.error("Error while waiting for events:", error);
      }
    }
    isRunning = false;
  }

  return (
    <>
      <div className="card">
        <button onClick={() => initialize()}>Initialize</button>
      </div>

      <div className="card">
        <button onClick={() => tick()}>Start Game</button>
      </div>

      <div className="card">
        <button onClick={() => startEventWatcher()}>Listen RPC</button>
      </div>
    </>
  );
}

export default App;
