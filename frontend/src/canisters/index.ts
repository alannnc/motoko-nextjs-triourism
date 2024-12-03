import { CandidCanister } from "@bundly/ares-core";

import { TestActor, test } from "./test";
import { BackendActor, backend } from "./backend";


export type CandidActors = {
  test: TestActor;
	backend: BackendActor
};

export let candidCanisters: Record<keyof CandidActors, CandidCanister> = {
  test,
	backend
};
