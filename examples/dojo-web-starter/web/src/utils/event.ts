import { InvokeTransactionReceiptResponse, shortString } from "starknet";

export enum RyoEvents {
  GameBlock = "GameBlock",
}

export interface BaseEventData {
  gameId: string;
}

export interface CreateEventData extends BaseEventData {
  blockNumber: number;
  tickerNumber: number;
}

export const parseEvent = (
  receipt: InvokeTransactionReceiptResponse,
  eventType: RyoEvents
): BaseEventData => {
  const raw = receipt.events?.find(
    (e) => shortString.decodeShortString(e.keys[0]) === eventType
  );

  if (!raw) {
    throw new Error(`event not found`);
  }

  switch (eventType) {
    case RyoEvents.GameBlock:
      return {
        gameId: "Tick",
        blockNumber: Number(raw.data[0]),
        tickerNumber: Number(raw.data[1]),
      } as CreateEventData;
      throw new Error(`event parse not implemented: ${eventType}`);
  }
};
