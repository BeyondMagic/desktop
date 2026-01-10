import Hyprland from "gi://AstalHyprland";
import { createBinding } from "ags"

// Return a fresh reference to the Hyprland service when needed
export function hyprland() {
	return Hyprland.get_default();
}

// Create a binding to the currently focused client using a fresh service reference
export function focused_client() {
	return createBinding(hyprland(), "focused_client");
}

// Create a binding to the monitors
export function monitors() {
	return createBinding(hyprland(), "monitors");
}