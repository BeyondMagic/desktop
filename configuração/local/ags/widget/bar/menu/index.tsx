import { Gtk } from "ags/gtk4"
import { config } from "../../../app"
import { createBinding } from "ags"
import { get_color_at_percentage } from "./color"

import Service from "gi://AstalBattery"

export function Menu() {
	const service = Service.get_default()
	const percentage = createBinding(service, "percentage")

	const batteryColors = [
		"#101657ff",
		"#337eb5ff",
		"#d36799ff",
	]

	const icon = (
		service.is_battery ? (
			<label
				css_classes={["battery"]}
				use_markup
				label={percentage((v) => {
					const percent = Math.trunc(v * 100)
					const color = get_color_at_percentage(batteryColors, percent)
					return `<span color="${color}">${percent}%</span>`
				})}
			/>
		) : (
			<image
				width_request={config.corner}
				height_request={config.corner}
				css_classes={["icon"]}
				icon_name="menu-navigation-open"
			/>
		)
	)

	return (
		<button
			css_classes={["menu"]}
		>
			{icon}
		</button>
	)
}