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
			class="calendar-popover"
		// visible
		>
			<box
				class="calendar"
				orientation={Gtk.Orientation.HORIZONTAL}
			>
				{/* <Gtk.Calendar /> */}
				<Calendar />
				<Events />
			</box>
		</popover>
	</menubutton>
}
