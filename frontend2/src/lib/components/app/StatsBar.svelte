<script lang="ts">
	import type { Snippet } from 'svelte';
	import { cn } from '$lib/utils.js';

	let {
		items,
		class: className,
		children,
	}: {
		items: {
			label: string;
			value: string | number | null | undefined;
			valueFirst?: boolean;
		}[];
		class?: string;
		children?: Snippet;
	} = $props();
</script>

<div
	class={cn(
		'flex flex-wrap items-center justify-between gap-3 text-sm',
		className,
	)}
>
	<dl class="flex flex-wrap items-center gap-2">
		{#each items as item (item.label)}
			<div class="flex items-center gap-2 rounded-lg bg-muted/50 px-3 py-2">
				<dt class="text-muted-foreground">{item.label}</dt>
				<dd
					class="text-base font-semibold tabular-nums"
					class:order-first={item.valueFirst !== false}
				>
					{#if typeof item.value === 'number'}
						{item.value.toLocaleString()}
					{:else}{item.value ?? '-'}{/if}
				</dd>
			</div>
		{/each}
	</dl>
	{#if children}{@render children()}{/if}
</div>
