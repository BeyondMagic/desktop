#!/usr/bin/env -S nu --stdin
#
# BeyondMagic 🄯 2025

export def main [
	action: string, # "switch" | "move"
	id_workspace: number
]: nothing -> nothing {
	let id_monitor = ^hyprctl activeworkspace | grep "monitorID" | awk '{print $2}' | into int
	let target_workspace = $id_monitor * 10 + $id_workspace

	if $action == "switch" {
		^hyprctl dispatch workspace $target_workspace
	} else if $action == "move" {
		^hyprctl dispatch movetoworkspace $target_workspace
	} else {
		error make {
			message: $"Unknown action: ($action). Expected 'switch' or 'move'."
			label: "workspace.nu"
		}
	}
}