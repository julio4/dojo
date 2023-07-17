import "./App.css";
import { useDojo } from "./DojoContext";
import { useComponentValue } from "@dojoengine/react";
import { Utils } from "@dojoengine/core";
import { RyoEvents } from "./utils/event";

function App() {
  const {
    systemCalls: { initialize, tick },
    components: { GameStats },
  } = useDojo();

  const entityId = BigInt(import.meta.env.VITE_ENTITY_ID);
  const gamestats = useComponentValue(
    GameStats,
    Utils.getEntityIdFromKeys([entityId])
  );

  return (
    <>
      <div className="card">
        <button onClick={() => initialize()}>Initialize</button>
      </div>

      <div className="card">
        <button onClick={() => tick()}>Start Game</button>
      </div>
    </>
  );
}

export default App;
