import { For, createState } from "ags"
import { execAsync } from "ags/process"
import { Astal, Gtk, Gdk } from "ags/gtk4"

import AstalApps from "gi://AstalApps"
import Graphene from "gi://Graphene"

import { dbus_address } from "../../app"
import GLib from "gi://GLib"

const { TOP, BOTTOM, LEFT, RIGHT } = Astal.WindowAnchor

export function Launcher() {
	let contentbox: Gtk.Box
	let searchentry: Gtk.Entry
	let win: Astal.Window

	const apps = new AstalApps.Apps()
	const [list, setList] = createState(new Array<AstalApps.Application>())

	function search(text: string) {
		if (text === "")
			setList([]);
		else
			setList(apps.fuzzy_query(text).slice(0, 8));
	}

	async function launch(app?: AstalApps.Application) {
		if (!app) return;
		win.hide();

		// Prefer gtk-launch with the application entry name so desktop file Exec flags are honored
		// and we avoid manually parsing the Exec field.
		const entry = app.entry || app.get_entry?.();
		if (entry) {
			try {
				await execAsync([
					"fork.nu",
					`exec gtk-launch ${entry}`
				]);
				return;
			} catch (e) {
				printerr(`gtk-launch failed for ${entry}: ${e}`);
			}
		}
		// Fallback to underlying API if gtk-launch not available or failed.
		try {
			app.launch();
		} catch (e) {
			printerr(`Fallback app.launch() failed: ${e}`);
		}
	}

	// close on ESC
	// handle alt + number key
	function onKey(
		_e: Gtk.EventControllerKey,
		keyval: number,
		_: number,
		mod: number,
	): void {
		if (keyval === Gdk.KEY_Escape) {
			win.visible = false
			return
		}

		if (mod === Gdk.ModifierType.ALT_MASK)
			for (const i of [1, 2, 3, 4, 5, 6, 7, 8, 9] as const) {
				if (keyval === (Gdk as any)[`KEY_${i}`]) {
					void launch(list.get()[i - 1]);
					return;
				}
			}

		// focus the search entry, if it's
		// a-z
		// A-Z
		// 0-9
		// space
		// backspace
		if (
			searchentry && (
				(keyval >= Gdk.KEY_a && keyval <= Gdk.KEY_z) ||
				(keyval >= Gdk.KEY_A && keyval <= Gdk.KEY_Z) ||
				(keyval >= Gdk.KEY_0 && keyval <= Gdk.KEY_9) ||
				keyval === Gdk.KEY_space ||
				keyval === Gdk.KEY_BackSpace
			)
		) {
			searchentry.grab_focus()

			let text = searchentry.get_text()

			// if backspace, remove last char
			if (keyval === Gdk.KEY_BackSpace) {
				text = text.slice(0, -1)
			} else {
				// insert the key into the entry
				const char = String.fromCharCode(Gdk.keyval_to_unicode(keyval))
				text += char
			}
			searchentry.set_text(text)
			searchentry.set_position(text.length)
			search(text)
		}
	}

	// close on clickaway
	function onClick(_e: Gtk.GestureClick, _: number, x: number, y: number) {
		const [, rect] = contentbox.compute_bounds(win)
		const position = new Graphene.Point({ x, y })

		if (!rect.contains_point(position)) {
			win.visible = false
			return true
		}
	}

	return (
		<window
			$={(ref) => (win = ref)}
			name="launcher"
			anchor={TOP | BOTTOM | LEFT | RIGHT}
			exclusivity={Astal.Exclusivity.IGNORE}
			keymode={Astal.Keymode.EXCLUSIVE}
			onNotifyVisible={({ visible }) => {
				if (visible) searchentry.grab_focus()
				else searchentry.set_text("")
			}}
		>
			<Gtk.EventControllerKey onKeyPressed={onKey} />
			<Gtk.GestureClick onPressed={onClick} />
			<box
				$={(ref) => (contentbox = ref)}
				valign={Gtk.Align.CENTER}
				halign={Gtk.Align.CENTER}
				orientation={Gtk.Orientation.VERTICAL}
				spacing={5}
			>
				<entry
					$={(ref) => (searchentry = ref)}
					onNotifyText={({ text }) => search(text)}
					onActivate={() => {
						const l = list.get();
						if (l.length > 0) launch(l[0]);
					}}
					placeholderText="Start typing to search"
				/>
				<Gtk.Separator visible={list((l) => l.length > 0)} />
				<box orientation={Gtk.Orientation.VERTICAL}>
					<For each={list}>
						{(app, index) => (
							<button onClicked={() => launch(app)}>
								<box
									spacing={8}
								>
									<image iconName={app.iconName} />
									<label
										class="app"
										label={app.name} maxWidthChars={40} wrap />
									<label
										class="shortcut"
										hexpand
										halign={Gtk.Align.END}
										label={index((i) => `∷${i + 1}`)}
									/>
								</box>
							</button>
						)}
					</For>
				</box>
			</box>
		</window>
	)
}