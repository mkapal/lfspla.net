<script lang="ts">
	import { page } from '$app/state';
	import CircleHelpIcon from '@lucide/svelte/icons/circle-help';
	import { Button } from '$lib/components/ui/button/index.js';
	import type { Snippet } from 'svelte';
	import type { LayoutProps } from './$types';

	let { data, children }: LayoutProps & { children: Snippet } = $props();
</script>

{#if page.route.id !== '/hotlaps/[era]/rankings/[rank]' && page.route.id !== '/hotlaps/[era]/rankings/[rank]/combinations'}
	<div class="flex justify-end">
		<Button
			variant="outline"
			href={`/hotlaps/${data.era.id}/rankings/${data.ranking.id}/combinations`}
		>
			<CircleHelpIcon />
			Rank Info
		</Button>
	</div>
{/if}

{@render children()}
