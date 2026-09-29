<script lang="ts">
	import { cn } from '$lib/utils.js';

	let {
		code,
		fallback,
		class: className,
	}: {
		code?: string | null;
		fallback?: string | null;
		class?: string;
	} = $props();

	const resolvedCode = $derived(code || fallback);
	const slug = $derived(resolvedCode?.toLowerCase() ?? '');
</script>

{#if resolvedCode}
	<img
		src="https://flagcdn.com/20x15/{slug}.png"
		srcset="https://flagcdn.com/40x30/{slug}.png 2x"
		width="20"
		height="15"
		loading="lazy"
		alt="{resolvedCode} flag"
		title={resolvedCode}
		class={cn(
			'inline-block shrink-0 rounded-[1px] align-middle shadow-sm',
			className,
		)}
	/>
{/if}
