import {
  get,
  query,
  type PaginatedResponse,
  type WorldRecordHolderResponse,
} from "$lib/api.js";
import type { PageLoad } from "./$types";

export const load: PageLoad = async ({ depends, fetch, parent, url }) => {
  depends("app:hotlaps");
  const { era } = await parent();
  const holders = await get<PaginatedResponse<WorldRecordHolderResponse>>(
    fetch,
    `/api/v1/eras/${encodeURIComponent(era.id)}/world-records` +
      query({
        page: url.searchParams.get("wr_page"),
        per_page: 25,
      }),
  );
  return {
    holders: holders.items,
    pagination: holders.pagination,
  };
};
