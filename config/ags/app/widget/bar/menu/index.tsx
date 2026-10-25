import { Gtk } from "ags/gtk4"
import { config } from "../../../app"
import { get_color_at_percentage } from "../../../lib/color"
import { batteryPercentage, isBattery } from "../../../services/battery"

export function Menu() {
	const percentage = batteryPercentage()

	const batteryColors = [
		"#101657ff",
		"#337eb5ff",
		"#d36799ff",
	]

	const icon = (
		isBattery() ? (
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