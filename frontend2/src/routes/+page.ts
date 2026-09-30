import { get, type StatsResponse } from "$lib/api.js";
import type { PageLoad } from "./$types";

export const load: PageLoad = async ({ depends, fetch }) => {
  depends("app:hotlaps");
  const stats = await get<StatsResponse>(fetch, "/api/v1/stats").catch(
    () => null,
  );
  return { stats };
};
