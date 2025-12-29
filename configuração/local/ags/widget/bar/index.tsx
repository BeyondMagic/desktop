import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import { onCleanup } from "ags"

import { Icon } from "./icon"
import { Title } from "./title"
import { Date } from "./date"
import { Tray } from "./tray"
import { Workspaces } from "./workspaces"
import { Menu } from "./menu"
// import { config } from "../../app"

export function Bar({ monitor }: { monitor: number }) {
	const { TOP, LEFT, RIGHT } = Astal.WindowAnchor;

	return <window
		name={"bar"}
		class="bar"
		exclusivity={Astal.Exclusivity.EXCLUSIVE}
		monitor={monitor}
		anchor={TOP | LEFT | RIGHT}
		application={app}
		// BACKGROUND: makes impossible to interact if a window is maximized, although appears behind transparent windows
		// TOP: makes possible to interact if a window is maximized, although disappears behind transparent windows
		// FIXME: is it possible to have TOP's interaction with maximized windows and still appear above transparent windows?
		layer={Astal.Layer.TOP}
		$={(self) => onCleanup(() => self.destroy())}
		visible
	>
		<centerbox cssName="centerbox">
			{/* Information of current window. */}
			<box
				$type="start"
			>
				<Icon />
				<Title />
			</box>

			{/* Date and time. */}
			<Date />

			{/* Workspaces and system trays. */}
			<box
				$type="end"
			>

				<Workspaces monitor={monitor} />
				{/* To-do: The height is 100%, so commenting this for now. */}
				{/* <Gtk.Separator
						orientation={Gtk.Orientation.VERTICAL}
						height_request={5}
						visible={true}
					/> */}
				<Tray />

				<Menu />
			</box>

		</centerbox>
	</window>;
}