import Tray from "gi://AstalTray"

export function astal_tray() {
	return Tray.get_default();
}