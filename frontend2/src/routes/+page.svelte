<script lang="ts">
	import { artworkFor } from '$lib/assets/artwork.js';
	import HotlapActivity from '$lib/components/app/HotlapActivity.svelte';
	import Flag from '$lib/components/app/Flag.svelte';
	import PageHeading from '$lib/components/app/PageHeading.svelte';
	import StatsBar from '$lib/components/app/StatsBar.svelte';
	import xrgImage from '$assets/builtin-vehicles/XRG.png?url';
	import * as Card from '$lib/components/ui/card/index.js';
	import type { PageProps } from './$types';

	let { data }: PageProps = $props();

	const stats = $derived([
		{ label: 'Hotlaps', value: data.stats?.validated_hotlaps },
		{ label: 'Drivers', value: data.stats?.drivers },
		{ label: 'Combinations', value: data.stats?.combinations },
		{ label: 'Eras', value: data.stats?.eras },
	]);
	const trackArtwork = artworkFor('track', 'BL1');
</script>

<main
	id="main"
	class="mx-auto w-full max-w-screen-2xl flex-1 space-y-6 p-4 md:p-6"
>
	<section class="grid gap-6 xl:grid-cols-[minmax(0,1fr)_auto] xl:items-center">
		<PageHeading title="A new home for Live for Speed data.">
			A community-built alternative to LFS World-starting with validated hotlaps
			and (hopefully) growing to include online results, personal bests,
			statistics, and driver history.
		</PageHeading>
		<StatsBar items={stats} class="xl:justify-end" />
	</section>

	<div
		class="grid min-w-0 items-start gap-8 xl:grid-cols-[minmax(0,2fr)_minmax(18rem,1fr)]"
	>
		<HotlapActivity
			refreshKey={data.stats}
			views={['all', 'world_records', 'mine']}
			perPage={10}
			eras={data.eras}
		/>
		<div class="space-y-4">
			<Card.Root class="gap-2 bg-muted/40 py-4 shadow-none ring-0">
				<Card.Header>
					<Card.Title id="home-spotlight-title" class="text-base font-semibold">
						Combo spotlight
					</Card.Title>
					<Card.Description>Era / Track / Vehicle</Card.Description>
					<Card.Action class="self-center">
						<div
							class="relative h-12 w-20 overflow-hidden rounded-md bg-muted/40"
							aria-hidden="true"
						>
							{#if trackArtwork && 'markup' in trackArtwork}
								<div
									class="absolute inset-0 [&>svg]:size-full [&>svg]:rotate-90 [&>svg]:scale-150"
								>
									{@html trackArtwork.markup}
								</div>
							{/if}
							<img
								src={xrgImage}
								alt=""
								class="absolute right-0 bottom-1 w-14 object-contain"
							/>
						</div>
					</Card.Action>
				</Card.Header>
				<Card.Content>
					<div class="space-y-1.5">
						<div class="flex items-center justify-between gap-3">
							<div class="flex min-w-0 items-center gap-2">
								<Flag code="gb" />
								<p class="truncate text-sm font-medium">Driver name</p>
							</div>
							<p
								class="shrink-0 font-mono text-sm font-semibold tabular-nums text-time-best"
							>
								--:--.---
							</p>
						</div>
						<div class="flex items-center justify-between gap-3">
							<div class="flex min-w-0 items-center gap-2">
								<Flag code="de" />
								<p class="truncate text-sm">Driver name</p>
							</div>
							<p
								class="shrink-0 font-mono text-xs tabular-nums text-muted-foreground"
							>
								+0:0.513
							</p>
						</div>
						<div class="flex items-center justify-between gap-3 opacity-40">
							<div class="flex min-w-0 items-center gap-2">
								<Flag code="fi" />
								<p class="truncate text-sm">Driver name</p>
							</div>
							<p
								class="shrink-0 font-mono text-xs tabular-nums text-muted-foreground"
							>
								+0:1.204
							</p>
						</div>
					</div>
				</Card.Content>
			</Card.Root>
			<Card.Root class="gap-2 bg-muted/40 py-4 shadow-none ring-0">
				<Card.Header>
					<Card.Title class="text-base font-semibold">
						Driver spotlight
					</Card.Title>
					<Card.Description>Most new personal bests recently</Card.Description>
				</Card.Header>
				<Card.Content>
					<div class="flex items-center justify-between gap-3">
						<div class="flex min-w-0 items-center gap-2">
							<Flag code="gb" />
							<p class="truncate text-sm font-medium">Driver name</p>
						</div>
						<p class="shrink-0 text-sm text-muted-foreground">N new PBs</p>
					</div>
				</Card.Content>
			</Card.Root>
		</div>
	</div>
</main>
