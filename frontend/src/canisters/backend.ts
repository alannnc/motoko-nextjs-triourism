import { ActorSubclass } from "@dfinity/agent";

import { CandidCanister } from "@bundly/ares-core";

import { _SERVICE, idlFactory } from "../declarations/backend/backend.did.js";

export type BackendActor = ActorSubclass<_SERVICE>;

export const backend: CandidCanister = {
  idlFactory,
  actorConfig: {
		canisterId: process.env.NEXT_PUBLIC_BACKEND_CANISTER_ID!,
  },
};
