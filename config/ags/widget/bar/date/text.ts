import { createPoll } from "ags/time"

import GLib from "gi://GLib";

const cycle_kanji = {
	total: 4,
	current: 0
}

export function text() {
	return createPoll(
		"",
		1000,
		() => {
			const date = GLib.DateTime.new_now_local().format('%B%d%A###%I時%M分')!;

			// Make all Japanese characters with lower opacity.
			const date_jp = date.replace(/([一-龯]+)/g, kanji => {
				let alpha = 75
				3
				if (cycle_kanji.current < 2)
					alpha = 35

				cycle_kanji.current = (cycle_kanji.current + 1) % cycle_kanji.total

				return '<span fgalpha="' + alpha + '%">' + kanji + '</span>'
			})

			const [left, right] = date_jp.split("###");

			return `<span fgalpha="50%" font="10" font_weight="bold" rise="1pt">${left}</span> <span font="11.9" font_weight="bold">${right}</span>`;
		}
	)
}