import { createBinding, createState, createEffect } from "ags"
import { focused_client, hyprland } from "../../../services/hyprland"
import { config } from "../../../app"
import { resolveCategory } from "./map"

const FALLBACK_ICON = "unknown-status-symbolic";

export function Icon({ monitor }: { monitor: number }) {
	const [lastIcon, setLastIcon] = createState("");
	const focused = focused_client();
	const focusedMonitor = createBinding(hyprland(), "focused_monitor");

	createEffect(() => {
		const client = focused();
		const fm = focusedMonitor();

		if (client && client.monitor?.id === monitor) {
			const clientClass = createBinding(client, "class");
			const clientTitle = createBinding(client, "initial_title");
			const category = resolveCategory({
				className: clientClass(),
				title: clientTitle(),
			});
			if (!category) {
				if (clientClass.peek())
					printerr("No category found for class:", clientClass.peek());
				if (clientTitle.peek())
					printerr("No category found for title:", clientTitle.peek());
			}
			setLastIcon(category ?? FALLBACK_ICON);
		} else if (!client && fm?.id === monitor) {
			setLastIcon("");
		}
		// Otherwise: focus is elsewhere — keep frozen lastIcon
	});

	return <box>
		<image
			width_request={config.corner}
			height_request={config.corner}
			css_classes={["icon"]}
			icon_name={lastIcon}
		/>
	</box>
}