import { Gtk } from "ags/gtk4"
import { hyprland } from "../../../services/hyprland";
import { createBinding, createComputed } from "ags"
import { config } from "../../../app";
import type Hyprland from "gi://AstalHyprland";

const focused = createBinding(hyprland(), "focused_workspace")

export function Workspace ({ ws, fallbackLabel } : { ws: Hyprland.Workspace; fallbackLabel?: string })
{
	const clients = createBinding(ws, "clients")

	const name = createBinding(ws, "name").as((n) => {
		// printerr("[workspace] name binding called for workspace", ws.id, "with n:", n, "and fallbackLabel:", fallbackLabel);
		const fallback = fallbackLabel ?? `ws ${ws.id}`;
		if (n == null)
			return fallback;
		if (`${n}` === `${ws.id}`)
			return fallback;
		return n;
	})

	const classes = createComputed([clients, focused], (cs, f) => {
		const result = ["workspace"]
		if (cs.length === 0)
			result.push("empty")
		if (f === ws)
			result.push("focus")
		return result
	})

	return (
		<Gtk.Button
			css_classes={classes}
			label={name}
			width_request={config.corner}
			height_request={config.corner}
			onClicked={() => {
				hyprland().message(`dispatch workspace ${ws.id}`)
			}}
		/>
	)

}