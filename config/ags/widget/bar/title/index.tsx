import { Astal, Gtk, Gdk } from "ags/gtk4"
import { config } from "../../../app"
import { Label } from "./label"

export function Title() {
	return <scrolledwindow
		propagate_natural_width
		vscrollbar_policy={Gtk.PolicyType.NEVER}
		maxContentWidth={config.title_max_width}
	>
		<Label />
	</scrolledwindow>
}