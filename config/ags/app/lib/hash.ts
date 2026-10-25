export function hash_u32_fnv1a(input: string) {
	let hash = 0x811c9dc5;
	for (let i = 0; i < input.length; i++) {
		hash ^= input.charCodeAt(i);
		hash = Math.imul(hash, 0x01000193);
	}
	return hash >>> 0;
}

export function color_class_for_event_title(title?: string) {
	const normalized = (title ?? "").trim() || "Untitled";
	const color_index = (hash_u32_fnv1a(normalized) % 16) + 1;
	return `color-${color_index}`;
}

