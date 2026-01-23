import Gtk from "gi://Gtk?version=4.0"
import Gdk from "gi://Gdk?version=4.0"
import Adw from "gi://Adw"
import GLib from "gi://GLib"
import Pango from "gi://Pango"

export type NotificationAction = {
	id: string
	label: string
}

export type NotificationLike = {
	id: number
	time: number
	appName: string
	appIcon?: string | null
	desktopEntry?: string | null
	summary: string
	body?: string | null
	image?: string | null
	actions: NotificationAction[]
	urgency: number
	dismiss: () => void
	invoke: (actionId: string) => void
}

function is_icon(icon?: string | null) {
	const iconTheme = Gtk.IconTheme.get_for_display(Gdk.Display.get_default()!)
	return icon && iconTheme.has_icon(icon)
}

function file_exists(path: string) {
	return GLib.file_test(path, GLib.FileTest.EXISTS)
}

function time(time: number, format = "%H:%M") {
	return GLib.DateTime.new_from_unix_local(time).format(format)!
}

function urgency(n: NotificationLike) {
	switch (n.urgency) {
		case 0:
			return "low"
		case 2:
			return "critical"
		case 1:
		default:
			return "normal"
	}
}

export default function Notification({
	notification: n,
	onHoverLost,
}: {
	notification: NotificationLike
	onHoverLost: () => void
}) {

	const width = 400;

	return (
		<Adw.Clamp maximumSize={width}>
			<box
				widthRequest={width}
				class={`notification ${urgency(n)}`}
				orientation={Gtk.Orientation.VERTICAL}
			>
				{/* <Gtk.EventControllerMotion
					onLeave={onHoverLost}
				/> */}
				<box class="header">
					{(n.appIcon || is_icon(n.desktopEntry)) && (
						<image
							class="app-icon"
							visible={Boolean(n.appIcon || n.desktopEntry)}
							iconName={n.appIcon ?? n.desktopEntry ?? undefined}
						/>
					)}
					<label
						class="app-name"
						halign={Gtk.Align.START}
						ellipsize={Pango.EllipsizeMode.END}
						label={n.appName || "Unknown"}
					/>
					<label
						class="time"
						hexpand
						halign={Gtk.Align.END}
						label={time(n.time)}
					/>
					<button onClicked={() => n.dismiss()}>
						<image iconName="window-close-symbolic" />
					</button>
				</box>
				<Gtk.Separator visible />
				<box class="content">
					{n.image && file_exists(n.image) && (
						<image valign={Gtk.Align.START} class="image" file={n.image} />
					)}
					{n.image && is_icon(n.image) && (
						<box valign={Gtk.Align.START} class="icon-image">
							<image
								iconName={n.image}
								halign={Gtk.Align.CENTER}
								valign={Gtk.Align.CENTER}
							/>
						</box>
					)}
					<box orientation={Gtk.Orientation.VERTICAL}>
						<label
							class="summary"
							halign={Gtk.Align.START}
							xalign={0}
							label={n.summary}
							ellipsize={Pango.EllipsizeMode.END}
						/>
						{n.body && (
							<label
								class="body"
								wrap
								useMarkup
								halign={Gtk.Align.START}
								xalign={0}
								justify={Gtk.Justification.FILL}
								label={n.body}
							/>
						)}
					</box>
				</box>
				{n.actions.length > 0 && (
					<box class="actions">
						{n.actions.map(({ label, id }) => (
							<button hexpand onClicked={() => n.invoke(id)}>
								<label label={label} halign={Gtk.Align.CENTER} hexpand />
							</button>
						))}
					</box>
				)}
			</box>
		</Adw.Clamp>
	)
}