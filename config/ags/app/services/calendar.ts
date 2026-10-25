import GLib from "gi://GLib";
import { createState } from "ags";
import { google } from "../widget/bar/date/google";
import { ensure_date, is_same_date, is_same_month, to_glib_datetime, day_bounds } from "../lib/date";
import { color_class_for_event_title } from "../lib/hash";

export type DayCell = {
	label: string;
	css_classes: string[];
	tooltip_text?: string;
}

export type CalendarView = {
	base: GLib.DateTime;
	month_label: string;
	year_label: string;
	weeks: DayCell[][];
	is_current_month: boolean;
}

export type CalendarEvent = {
	title: string;
	description?: string;
	start: Date;
	end: Date;
	id: string;
	type: string;
}

// Time range is in years, so 3 means we fetch events from 3 years ago to 3 years in the future.
const time_range = 3;

export const WEEKDAY_LABELS = [
	{
		label: "日",
		weekday: false,
	},
	{
		label: "月",
		weekday: true,
	},
	{
		label: "火",
		weekday: true,
	},
	{
		label: "水",
		weekday: true,
	},
	{
		label: "木",
		weekday: true,
	},
	{
		label: "金",
		weekday: true,
	},
	{
		label: "土",
		weekday: false,
	}
] as const;

export const DEFAULT_SPACING = 6;
export const REFRESH_RATE = 60_000; // 1 minute in milliseconds
export const REFRESH_RATE_FIRST = 1_000; // 3 seconds in milliseconds
export const [events_state, set_events_state] = createState(new Array<CalendarEvent>());
let events_loaded = false;
let events_loading: Promise<CalendarEvent[]> | null = null;
let refresh_calendar_view: (() => void) | null = null;

export function set_refresh_calendar_view(fn: (() => void) | null) {
	refresh_calendar_view = fn;
}

export async function refresh_events() {
	const now = GLib.DateTime.new_now_local();
	const time_min = ensure_date(now.get_year() - time_range, 1, 1).format("%FT%T") ?? "";
	const time_max = ensure_date(now.get_year() + time_range, 12, 31).format("%FT%T") ?? "";
	const events = await google.events({ time_min, time_max }) as CalendarEvent[];
	set_events_state(events);
	refresh_calendar_view?.();
	return events;
}

export function ensure_events_loaded(onLoad?: (events: CalendarEvent[]) => void) {
	if (events_loaded) {
		onLoad?.(events_state.peek());
		return;
	}

	if (events_loading) {
		events_loading.then((events) => onLoad?.(events));
		return;
	}

	events_loading = refresh_events().then((events) => {
		events_loaded = true;
		events_loading = null;
		onLoad?.(events);
		return events;
	});
}

function event_overlaps_day(event: CalendarEvent, day: GLib.DateTime) {
	if (event.type === "birthday") {
		const event_start = to_glib_datetime(event.start);
		return event_start.get_month() === day.get_month()
			&& event_start.get_day_of_month() === day.get_day_of_month();
	}
	const { day_start, day_end } = day_bounds(day);
	const event_start = to_glib_datetime(event.start);
	const event_end = to_glib_datetime(event.end);
	return event_start.compare(day_end) < 0 && event_end.compare(day_start) > 0;
}

function event_tooltip_line(event: CalendarEvent) {
	const title = event.title?.trim() || "Untitled";
	const description = event.description?.trim();
	return description ? `${title}: ${description}` : title;
}

function add_span_edge_classes(week_days: DayCell[]) {
	const span_types = ["event", "birthday"] as const;

	for (const span_type of span_types) {
		for (let index = 0; index < week_days.length; index++) {
			const day_cell = week_days[index];
			if (!day_cell)
				continue;
			if (!day_cell.css_classes.includes(span_type))
				continue;

			const prev_same = index > 0 && week_days[index - 1]?.css_classes.includes(span_type);
			const next_same = index < week_days.length - 1 && week_days[index + 1]?.css_classes.includes(span_type);

			if (!prev_same && !day_cell.css_classes.includes("edge-left"))
				day_cell.css_classes.push("edge-left");
			if (!next_same && !day_cell.css_classes.includes("edge-right"))
				day_cell.css_classes.push("edge-right");
		}
	}

	return week_days;
}

function build_weeks(first_day: GLib.DateTime, events: CalendarEvent[]): DayCell[][] {
	const today_date = GLib.DateTime.new_now_local();
	const month = first_day.get_month();
	const start_weekday = first_day.get_day_of_week() % 7;
	let cursor = first_day.add_days(-start_weekday) ?? first_day;
	const weeks: DayCell[][] = [];

	for (let week_index = 0; week_index < 6; week_index++) {
		let week_days: DayCell[] = [];

		for (let day_index = 0; day_index < 7; day_index++) {
			const is_current_month = cursor.get_month() === month;
			const classes = ["day"];
			if (day_index === 0 || day_index === 6)
				classes.push("weekend");
			
			const day_events = events.filter((event) => event_overlaps_day(event, cursor));
			const has_birthday = day_events.some((event) => event.type === "birthday");
			const has_default = day_events.some((event) => event.type === "default");
			let default_color_title: string | undefined;
			if (has_default) {
				for (const event of day_events) {
					if (event.type !== "default")
						continue;
					const candidate = event.title?.trim() || "Untitled";
					if (default_color_title === undefined || candidate.localeCompare(default_color_title) < 0)
						default_color_title = candidate;
				}
			}
			const tooltip_text = day_events.length > 0
				? day_events.map(event_tooltip_line).join("\n")
				: undefined;

			if (!is_current_month)
				classes.push("inactive");

			if (is_same_date(cursor, today_date))
				classes.push("today");

			if (has_birthday)
				classes.push("birthday");

			if (has_default)
				classes.push("event");

			if (has_default)
				classes.push(color_class_for_event_title(default_color_title));

			week_days.push({
				label: cursor.get_day_of_month().toString(),
				css_classes: classes,
				tooltip_text,
			});

			cursor = cursor.add_days(1) ?? cursor;
		}

		week_days = add_span_edge_classes(week_days);

		weeks.push(week_days);
	}

	return weeks;
}

export function build_calendar_view(date: GLib.DateTime, events: CalendarEvent[]): CalendarView {
	const first_day = ensure_date(date.get_year(), date.get_month(), 1);
	const month_label = first_day.format("%B") ?? "Month";
	const year_label = first_day.format("%Y") ?? first_day.get_year().toString();
	const now = GLib.DateTime.new_now_local();

	return {
		base: first_day,
		month_label,
		year_label,
		weeks: build_weeks(first_day, events),
		is_current_month: is_same_month(first_day, now),
	};
}

export type EventSpan = "today" | "week" | "month" | "year";

export function range_for_span(span: EventSpan) {
	const now = GLib.DateTime.new_now_local();
	if (span === "today") {
		const day_start = ensure_date(now.get_year(), now.get_month(), now.get_day_of_month());
		const day_end = day_start.add_days(1) ?? day_start;
		return { range_start: day_start, range_end: day_end };
	}

	if (span === "week") {
		const start_weekday = now.get_day_of_week() % 7;
		const week_start = now.add_days(-start_weekday) ?? now;
		const week_end = week_start.add_days(7) ?? week_start;
		const range_start = ensure_date(week_start.get_year(), week_start.get_month(), week_start.get_day_of_month());
		return { range_start, range_end: week_end };
	}

	if (span === "month") {
		const month_start = ensure_date(now.get_year(), now.get_month(), 1);
		const month_end = month_start.add_months(1) ?? month_start;
		return { range_start: month_start, range_end: month_end };
	}

	const year_start = ensure_date(now.get_year(), 1, 1);
	const year_end = year_start.add_years(1) ?? year_start;
	return { range_start: year_start, range_end: year_end };
}

export function event_overlaps_range(event: CalendarEvent, range_start: GLib.DateTime, range_end: GLib.DateTime) {
	if (event.type === "birthday") {
		const event_start = to_glib_datetime(event.start);
		const month = event_start.get_month();
		const day = event_start.get_day_of_month();
		for (let year = range_start.get_year(); year <= range_end.get_year(); year++) {
			const candidate = ensure_date(year, month, day);
			if (candidate.compare(range_start) >= 0 && candidate.compare(range_end) < 0)
				return true;
		}
		return false;
	}
	const event_start = to_glib_datetime(event.start);
	const event_end = to_glib_datetime(event.end);
	return event_start.compare(range_end) < 0 && event_end.compare(range_start) > 0;
}

export function format_event_time(event: CalendarEvent) {
	const start = to_glib_datetime(event.start);
	const end = to_glib_datetime(event.end);
	const start_text = start.format("%b %d %H:%M") ?? "";
	const end_text = end.format("%b %d %H:%M") ?? "";
	return `${start_text} – ${end_text}`.trim();
}

