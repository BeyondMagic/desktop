import { Astal, Gtk, Gdk } from "ags/gtk4"
import { For, createState, onCleanup } from "ags"

import Notification, { type NotificationLike } from "../notification/util"
import {
	getPersistedNotifications,
	subscribeToPersistedNotifications,
	type PersistedNotification,
} from "../notification/storage"
import { config } from "../../app"

let menuWindow: Astal.Window | null = null

function toNotificationLike(entry: PersistedNotification): NotificationLike {
	return {
		id: entry.id,
		time: entry.time,
		appName: entry.appName,
		appIcon: entry.appIcon ?? undefined,
		desktopEntry: entry.desktopEntry ?? undefined,
		summary: entry.summary,
		body: entry.body ?? undefined,
		image: entry.imagePath ?? entry.imageIcon ?? undefined,
		actions: entry.actions ?? [],
		urgency: entry.urgency,
		dismiss: () => {},
		invoke: () => {},
	}
}

export function MenuWindow() {
	const [history, setHistory] = createState(
		getPersistedNotifications().map(toNotificationLike),
	)

	const unsubscribe = subscribeToPersistedNotifications((entries) => {
		setHistory(entries.map(toNotificationLike))
	})

	onCleanup(() => {
		unsubscribe()
	})

	const margin = config.corner * 0.5;

	return (
		<window
			$={(ref) => (menuWindow = ref)}
			name="menu"
			class="menu-history-window"
			anchor={Astal.WindowAnchor.TOP | Astal.WindowAnchor.RIGHT | Astal.WindowAnchor.BOTTOM}
			layer={Astal.Layer.OVERLAY}
			// exclusivity={Astal.Exclusivity.IGNORE}
			marginRight={margin}
			marginTop={margin}
			marginBottom={margin}
			visible={false}
			vexpand
		>
			{/* FIX-IT: Escape key not working. */}
			<Gtk.EventControllerKey
				onKeyPressed={(_, keyval) => {
					if (keyval === Gdk.KEY_Escape && menuWindow)
						menuWindow.visible = false
				}}
			/>
			<Gtk.ScrolledWindow
				css_classes={["menu-history-scroll"]}
				vexpand
				hexpand
				widthRequest={420}
				heightRequest={600}
			>
				<box
					orientation={Gtk.Orientation.VERTICAL}
					spacing={8}
					css_classes={["menu-history-list"]}
				>
					<For each={history}>
						{(entry) => (
							<Notification notification={entry} onHoverLost={() => { }} />
						)}
					</For>
				</box>
			</Gtk.ScrolledWindow>
		</window>
	)
}

export function toggleMenuWindow() {
	if (!menuWindow)
		return
	menuWindow.visible = !menuWindow.visible
}
