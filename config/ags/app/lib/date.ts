import GLib from "gi://GLib";

export function ensure_date(year: number, month: number, day = 1) {
	const dt = GLib.DateTime.new_local(year, month, day, 0, 0, 0);
	return dt ?? GLib.DateTime.new_now_local();
}

export function is_same_date(a: GLib.DateTime, b: GLib.DateTime) {
	return a.get_year() === b.get_year() &&
		a.get_month() === b.get_month() &&
		a.get_day_of_month() === b.get_day_of_month();
}

export function to_glib_datetime(date: Date) {
	const seconds = Math.floor(date.getTime() / 1000);
	return GLib.DateTime.new_from_unix_local(seconds);
}

export function day_bounds(day: GLib.DateTime) {
	const day_start = ensure_date(day.get_year(), day.get_month(), day.get_day_of_month());
	const day_end = day_start.add_days(1) ?? day_start;
	return { day_start, day_end };
}

export function is_same_month(a: GLib.DateTime, b: GLib.DateTime) {
	return a.get_year() === b.get_year() && a.get_month() === b.get_month();
}

