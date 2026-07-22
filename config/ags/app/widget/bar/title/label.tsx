import { createBinding, createState, createEffect } from "ags"
import { focused_client, hyprland } from "../../../services/hyprland"


export function Label({ monitor }: { monitor: number })
{
	const [lastTitle, setLastTitle] = createState("");
	const focused = focused_client();
	const focusedMonitor = createBinding(hyprland(), "focused_monitor");

	// Keep lastTitle in sync whenever the focused client is on our monitor
	createEffect(() => {
		const client = focused();
		const fm = focusedMonitor();

		if (client && client.monitor?.id === monitor) {
			// Focused client is on our monitor — track its title live
			const title = createBinding(client, "title");
			setLastTitle(title() ?? "");
		} else if (!client && fm?.id === monitor) {
			// No focused client, but our monitor is focused — clear the title
			setLastTitle("");
		}
		// Otherwise: client on another monitor or no focus elsewhere — keep frozen
	});

	return <label
		$type='end'
		css_classes={["title"]}
		label={lastTitle}
	/>
}