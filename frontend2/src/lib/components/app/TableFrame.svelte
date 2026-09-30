<script lang="ts">
	import type { Snippet } from 'svelte';
	import { cn } from '$lib/utils.js';

	let {
		class: className,
		children,
	}: {
		class?: string;
		children: Snippet;
	} = $props();
</script>

<div
	data-slot="table-frame"
	class={cn(
		'overflow-hidden rounded-xl bg-card text-card-foreground ring-1 ring-foreground/10',
		className,
	)}
>
	{@render children()}
</div>
