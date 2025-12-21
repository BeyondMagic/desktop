import app from "ags/gtk4/app"
import { Gtk } from "ags/gtk4";
import { For, This } from "ags"
import GLib from "gi://GLib";

import style from "./styles.scss"
import config from "./config.json";

import { monitors as get_hypr_monitors } from "./services/hyprland";

import { Bar } from "./widget/bar";
import { Corner } from "./widget/corner";
import { Launcher } from "./widget/launcher";
import { MenuWindow } from "./widget/menu";

import { NotificationPopups } from "./widget/notification"

let app_launcher: Gtk.Window;
let menu_window: Gtk.Window;

print("Astal Desktop starting...");
const dbus_address = GLib.getenv("DBUS_SESSION_BUS_ADDRESS") ?? "unix:path=/tmp/dbus";
print("DBUS_SESSION_BUS_ADDRESS:", dbus_address);

export {
	config,
	dbus_address
};

// https://wiki.hypr.land/Configuring/XWayland/

function main() {
	const hypr_monitors = get_hypr_monitors();

	app_launcher = Launcher() as Gtk.Window;
	app.add_window(app_launcher);

	menu_window = MenuWindow() as Gtk.Window;
	app.add_window(menu_window);

	return (
		<For each={hypr_monitors} >
			{(monitor) => {

				return (
					<This
						this={app}
					>
						<NotificationPopups monitor={monitor.id} />
						<Bar monitor={monitor.id} />
						<Corner vertical="bottom" horizontal="left" monitor={monitor.id} />
						<Corner vertical="bottom" horizontal="right" monitor={monitor.id} />
						<Corner vertical="top" horizontal="right" monitor={monitor.id} />
						<Corner vertical="top" horizontal="left" monitor={monitor.id} />
					</This>
				)
			}}
		</For>
	)
}

function request_handler(request: string, res: (response: any) => void) {
	const [, argv] = GLib.shell_parse_argv(request)

	if (!argv)
		return res("argv parse error")

	switch (argv[0]) {
		case "toggle":
			app_launcher.visible = !app_launcher.visible
			return res("ok")
		default:
			return res("unknown command")
	}
}


app.start({
	css: style,
	icons: `${SRC}/assets/`,
	requestHandler: request_handler,
	main
})