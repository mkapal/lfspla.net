<script lang="ts">
	import SortableHead from '$lib/components/app/SortableHead.svelte';
	import * as ToggleGroup from '$lib/components/ui/toggle-group/index.js';
	import { queryValue, updateQuery } from '$lib/query.js';
	import { useSession } from '$lib/session.svelte.js';
	import type { HotlapListColumn, Ordering } from '$lib/api.js';
	import * as Table from '$lib/components/ui/table/index.js';
	import * as Card from '$lib/components/ui/card/index.js';
	import Flag from '$lib/components/app/Flag.svelte';
	import CompareButton from '$lib/components/app/CompareButton.svelte';
	import PaginationControls from '$lib/components/app/PaginationControls.svelte';
	import Panel from '$lib/components/app/Panel.svelte';
	import { dateTime, lapTime } from '$lib/format.js';
	import { hotlapPath } from '$lib/era.js';
	import type { PageProps } from './$types';
	import { Badge } from '$lib/components/ui/badge/index.js';

	let { data }: PageProps = $props();
	const session = useSession();
	const column = $derived(
		(queryValue('column') || 'submitted') as HotlapListColumn,
	);
	const order = $derived((queryValue('order') || 'desc') as Ordering);
	const mine = $derived(queryValue('mine') === 'true');
</script>

<p class="text-sm text-muted-foreground">
	{#if data.era.open}
		This era is open for hotlap submissions and accepts replays recorded with
		LFS {data.era.version_requirement}.
	{:else}
		This historical era accepts replays recorded with LFS
		{data.era.version_requirement}.
	{/if}
</p>

<div
	class="grid min-w-0 items-start gap-6 xl:grid-cols-[minmax(0,2fr)_minmax(0,1fr)]"
>
	<div class="min-w-0">
		<Panel
			title="Upload log"
			description="Validated hotlaps in this era. Positions show current chart standings; - means the upload is not a ranked personal best."
			flush
		>
			{#snippet action()}
				<Card.Action>
					<ToggleGroup.Root
						type="single"
						value={mine ? 'mine' : 'all'}
						variant="outline"
						size="sm"
						aria-label="Filter hotlaps"
						onValueChange={(value) =>
							updateQuery('mine', value === 'mine' ? 'true' : '')}
					>
						<ToggleGroup.Item value="all">All</ToggleGroup.Item>
						{#if session.signedIn}<ToggleGroup.Item value="mine"
								>Mine</ToggleGroup.Item
							>{/if}
					</ToggleGroup.Root>
				</Card.Action>
			{/snippet}
			<Table.Root
				class="[&_th:first-child]:pl-4 [&_td:first-child]:pl-4 [&_th:last-child]:pr-4 [&_td:last-child]:pr-4"
			>
				<Table.Header
					><Table.Row>
						<SortableHead
							column="submitted"
							label="Submitted"
							activeColumn={column}
							{order}
						/>
						<SortableHead
							column="driver"
							label="Driver"
							activeColumn={column}
							{order}
						/>
						<Table.Head>Track / Vehicle</Table.Head>
						<SortableHead
							column="rank"
							label="Rank"
							activeColumn={column}
							{order}
						/>
						<Table.Head>Contributes to</Table.Head>
						<SortableHead
							column="lap_time"
							label="Lap time"
							activeColumn={column}
							{order}
						/>
					</Table.Row></Table.Header
				>
				<Table.Body>
					{#each data.activity as lap (lap.id)}
						<Table.Row>
							<Table.Cell class="text-muted-foreground"
								><time datetime={lap.created_at}
									>{dateTime(lap.created_at)}</time
								></Table.Cell
							>
							<Table.Cell>
								<div class="flex min-w-0 items-center gap-1">
									<Flag
										code={lap.player.flag_code}
										fallback={lap.player.country_code}
									/>
									<a
										class="min-w-0 truncate font-medium hover:underline"
										href="/drivers/{encodeURIComponent(
											lap.player.lfs_username,
										)}">{lap.player.display_name}</a
									>
									<CompareButton driver={lap.player} />
								</div>
							</Table.Cell>
							<Table.Cell
								>{#if lap.vehicle}<a
										class="hover:underline"
										href={`${hotlapPath(lap.era_id)}/charts/${encodeURIComponent(lap.track)}/${encodeURIComponent(lap.vehicle)}`}
										>{lap.track} / {lap.vehicle}</a
									>{:else}{lap.track} / -{/if}</Table.Cell
							>
							<Table.Cell class="tabular-nums">{lap.position ?? '-'}</Table.Cell
							>
							<Table.Cell>
								<div class="flex flex-wrap gap-1">
									{#each lap.contributes_to as ranking (ranking.id)}
										<Badge
											variant="outline"
											href={`${hotlapPath(lap.era_id)}/rankings/${encodeURIComponent(ranking.id)}`}
											>{ranking.title}</Badge
										>
									{:else}
										<span class="text-muted-foreground">-</span>
									{/each}
								</div>
							</Table.Cell>
							<Table.Cell class="font-mono tabular-nums"
								>{lapTime(lap.lap_time_ms)}</Table.Cell
							>
						</Table.Row>
					{:else}
						<Table.Row
							><Table.Cell
								colspan={7}
								class="py-8 text-center text-muted-foreground"
								>{data.activityPagination.total_items > 0
									? 'No hotlaps on this page. Choose another page below.'
									: 'No validated hotlaps in this era yet.'}</Table.Cell
							></Table.Row
						>
					{/each}
				</Table.Body>
			</Table.Root>
			<div class="p-4">
				<PaginationControls
					pagination={data.activityPagination}
					label="hotlaps"
				/>
			</div>
		</Panel>
	</div>
	<div class="min-w-0">
		<Panel title="World record holders" flush={data.holders.length > 0}>
			<p class="px-4 pt-4 pb-4 text-sm text-muted-foreground">
				Current world records across this era's charts, ordered by records held.
			</p>
			<Table.Root
				class="[&_th:first-child]:pl-4 [&_td:first-child]:pl-4 [&_th:last-child]:pr-4 [&_td:last-child]:pr-4"
			>
				<Table.Header>
					<Table.Row>
						<Table.Head>#</Table.Head>
						<Table.Head>Driver</Table.Head>
						<Table.Head class="text-right">World records</Table.Head>
					</Table.Row>
				</Table.Header>
				<Table.Body>
					{#each data.holders as holder (holder.player.id)}
						<Table.Row>
							<Table.Cell class="tabular-nums">{holder.position}</Table.Cell>
							<Table.Cell>
								<Flag
									code={holder.player.flag_code}
									fallback={holder.player.country_code}
									class="mr-1"
								/>
								<a
									class="font-medium hover:underline"
									href="/drivers/{encodeURIComponent(
										holder.player.lfs_username,
									)}">{holder.player.display_name}</a
								>
							</Table.Cell>
							<Table.Cell class="text-right font-semibold tabular-nums"
								>{holder.world_records.toLocaleString()}</Table.Cell
							>
						</Table.Row>
					{:else}
						<Table.Row>
							<Table.Cell
								colspan={3}
								class="py-8 text-center text-muted-foreground"
							>
								{data.pagination.total_items > 0
									? 'No holders on this page. Choose another page below.'
									: 'No world records in this era yet.'}
							</Table.Cell>
						</Table.Row>
					{/each}
				</Table.Body>
			</Table.Root>
			<div class="p-4">
				<PaginationControls
					pagination={data.pagination}
					label="holders"
					pageKey="wr_page"
				/>
			</div>
		</Panel>
	</div>
</div>
