import { execAsync } from "ags/process"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import { text } from "./text"
import { Calendar, Events } from "./calendar"

export function Date() {
	return <menubutton
		$type="center"
		hexpand
		halign={Gtk.Align.CENTER}
	>
		<label
			use_markup
			label={text()}
		/>
		<popover
			class="calendar"
		// visible
		>
			<box
				orientation={Gtk.Orientation.VERTICAL}
			>
				{/* <Gtk.Calendar /> */}
				<Calendar />
				<Events />
			</box>
		</popover>
	</menubutton>
}
