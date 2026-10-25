import Service from "gi://AstalBattery"
import { createBinding } from "ags"

export function battery() {
	return Service.get_default()
}

export function batteryPercentage() {
	return createBinding(battery(), "percentage")
}

export function isBattery() {
	return battery().is_battery
}
