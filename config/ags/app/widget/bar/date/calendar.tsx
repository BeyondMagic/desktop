import GLib from "gi://GLib";
import { Gtk } from "ags/gtk4"
import { For, createState, onCleanup } from "ags"
import { interval } from "ags/time"
import { google } from "./google";

type DayCell = {
	label: string;
	css_classes: string[];
	tooltip_text?: string;
}

type CalendarView = {
	base: GLib.DateTime;
	month_label: string;
	year_label: string;
	weeks: DayCell[][];
	is_current_month: boolean;
}

type CalendarEvent = {
	title: string;
	description?: string;
	start: Date;
	end: Date;
	id: string;
	type: string;
}

// Time range is in years, so 3 means we fetch events from 3 years ago to 3 years in the future.
const time_range = 3;

// const events = await google.events({
// 	time_min: ensure_date(GLib.DateTime.new_now_local().get_year() - time_range, 1, 1).format("%FT%T") ?? "",
// 	time_max: ensure_date(GLib.DateTime.new_now_local().get_year() + time_range, 12, 31).format("%FT%T") ?? "",
// });

const WEEKDAY_LABELS = ["日", "月", "火", "水", "木", "金", "土"] as const;
const DEFAULT_SPACING = 6;
const REFRESH_RATE = 60_000; // 1 minute in milliseconds
const DEBUG_EVENTS = true;

const [events_state, set_events_state] = createState(new Array<CalendarEvent>());
let events_loaded = false;
let events_loading: Promise<CalendarEvent[]> | null = null;
let refresh_calendar_view: (() => void) | null = null;

function debug_log(message: string) {
	if (!DEBUG_EVENTS)
		return;
	// eslint-disable-next-line no-console
	print(`[calendar] ${message}`);
}

async function refresh_events() {
	const now = GLib.DateTime.new_now_local();
	const time_min = ensure_date(now.get_year() - time_range, 1, 1).format("%FT%T") ?? "";
	const time_max = ensure_date(now.get_year() + time_range, 12, 31).format("%FT%T") ?? "";
	debug_log(`Refreshing events time_min=${time_min} time_max=${time_max}`);
	const events = await google.events({ time_min, time_max }) as CalendarEvent[];
	debug_log(`Loaded ${events.length} events`);
	if (events.length > 0) {
		const samples = events.slice(0, 3).map((event) => {
			return `${event.title || "Untitled"} | ${event.start.toISOString()} -> ${event.end.toISOString()} | ${event.type}`;
		});
		debug_log(`Sample events: ${samples.join(" || ")}`);
	}
	set_events_state(events);
	refresh_calendar_view?.();
	return events;
}

function ensure_events_loaded(onLoad?: (events: CalendarEvent[]) => void) {
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

function ensure_date(year: number, month: number, day = 1) {
	const dt = GLib.DateTime.new_local(year, month, day, 0, 0, 0);
	return dt ?? GLib.DateTime.new_now_local();
}

function is_same_date(a: GLib.DateTime, b: GLib.DateTime) {
	return a.get_year() === b.get_year() &&
		a.get_month() === b.get_month() &&
		a.get_day_of_month() === b.get_day_of_month();
}

function to_glib_datetime(date: Date) {
	const seconds = Math.floor(date.getTime() / 1000);
	return GLib.DateTime.new_from_unix_local(seconds);
}

function day_bounds(day: GLib.DateTime) {
	const day_start = ensure_date(day.get_year(), day.get_month(), day.get_day_of_month());
	const day_end = day_start.add_days(1) ?? day_start;
	return { day_start, day_end };
}

function event_overlaps_day(event: CalendarEvent, day: GLib.DateTime) {
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

function build_weeks(first_day: GLib.DateTime, events: CalendarEvent[]): DayCell[][] {
	const today_date = GLib.DateTime.new_now_local();
	const month = first_day.get_month();
	const start_weekday = first_day.get_day_of_week() % 7;
	let cursor = first_day.add_days(-start_weekday) ?? first_day;
	const weeks: DayCell[][] = [];
	const marked_days: string[] = [];

	for (let week_index = 0; week_index < 6; week_index++) {
		const week_days: DayCell[] = [];

		for (let day_index = 0; day_index < 7; day_index++) {
			const is_current_month = cursor.get_month() === month;
			const classes = ["day"];
			const day_events = events.filter((event) => event_overlaps_day(event, cursor));
			const has_birthday = day_events.some((event) => event.type === "birthday");
			const has_default = day_events.some((event) => event.type === "default");
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

			if (day_events.length > 0) {
				marked_days.push(
					`${cursor.get_year()}-${cursor.get_month()}-${cursor.get_day_of_month()}:${day_events.length}`,
				);
			}

			week_days.push({
				label: cursor.get_day_of_month().toString(),
				css_classes: classes,
				tooltip_text,
			});

			cursor = cursor.add_days(1) ?? cursor;
		}

		weeks.push(week_days);
	}

	if (DEBUG_EVENTS) {
		debug_log(`Month ${first_day.get_year()}-${first_day.get_month()} has ${marked_days.length} marked days`);
		if (marked_days.length > 0)
			debug_log(`Marked days: ${marked_days.slice(0, 20).join(", ")}`);
	}

	return weeks;
}

function is_same_month(a: GLib.DateTime, b: GLib.DateTime) {
	return a.get_year() === b.get_year() && a.get_month() === b.get_month();
}

function build_calendar_view(date: GLib.DateTime, events: CalendarEvent[]): CalendarView {
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

type EventSpan = "today" | "week" | "month" | "year";

function range_for_span(span: EventSpan) {
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

function event_overlaps_range(event: CalendarEvent, range_start: GLib.DateTime, range_end: GLib.DateTime) {
	const event_start = to_glib_datetime(event.start);
	const event_end = to_glib_datetime(event.end);
	return event_start.compare(range_end) < 0 && event_end.compare(range_start) > 0;
}

function format_event_time(event: CalendarEvent) {
	const start = to_glib_datetime(event.start);
	const end = to_glib_datetime(event.end);
	const start_text = start.format("%b %d %H:%M") ?? "";
	const end_text = end.format("%b %d %H:%M") ?? "";
	return `${start_text} – ${end_text}`.trim();
}

export function Calendar() {
	const nav_arrows = {
		left: "◀",
		right: "▶",
	} as const;

	const [calendar_view, set_calendar_view] = createState(
		build_calendar_view(GLib.DateTime.new_now_local(), events_state.peek()),
	);

	refresh_calendar_view = () => {
		debug_log("Refreshing calendar view with loaded events");
		set_calendar_view((current_view: CalendarView) =>
			build_calendar_view(current_view.base, events_state.peek()),
		);
	};

	ensure_events_loaded(() => {
		refresh_calendar_view?.();
	});

	const refresh_today_highlight = () => {
		// print("Refreshing today's highlight");
		set_calendar_view((current_view: CalendarView) => {
			const now = GLib.DateTime.new_now_local();
			if (!current_view.is_current_month)
				return current_view;
			return build_calendar_view(now, events_state.peek());
		});
	};

	const refresh_tick = interval(REFRESH_RATE, refresh_today_highlight);

	onCleanup(() => {
		refresh_tick?.cancel();
		refresh_calendar_view = null;
	});

	function shift_month(delta: number) {
		set_calendar_view((current_view: CalendarView) => {
			const next_base = current_view.base.add_months(delta);
			return build_calendar_view(next_base ?? current_view.base, events_state.peek());
		});
	}

	function shift_year(delta: number) {
		set_calendar_view((current_view: CalendarView) => {
			const next_base = current_view.base.add_years(delta);
			return build_calendar_view(next_base ?? current_view.base, events_state.peek());
		});
	}

	return (
		<box
			class="grid"
			orientation={Gtk.Orientation.VERTICAL}
			spacing={DEFAULT_SPACING}
		>
			<box
				class="navigation"
				spacing={DEFAULT_SPACING * 2}
				vexpand={false}
			>
				<box
					class="section"
					spacing={DEFAULT_SPACING / 2}
				>
					<button
						onClicked={() => shift_month(-1)}
						label={nav_arrows.left}
					/>
					<label
						vexpand
						valign={Gtk.Align.CENTER}
						label={calendar_view((calendar_state: CalendarView) => calendar_state.month_label)}
					/>
					<button
						onClicked={() => shift_month(1)}
						label={nav_arrows.right}
					/>
				</box>
				<box hexpand />
				<box
					class="section"
					spacing={DEFAULT_SPACING / 2}
				>
					<button
						onClicked={() => shift_year(-1)}
						label={nav_arrows.left}
					/>
					<label
						valign={Gtk.Align.CENTER}
						label={calendar_view((calendar_state: CalendarView) => calendar_state.year_label)}
					/>
					<button
						onClicked={() => shift_year(1)}
						label={nav_arrows.right}
					/>
				</box>
			</box>
			<Gtk.Separator />
			<box
				orientation={Gtk.Orientation.VERTICAL}
				// spacing={DEFAULT_SPACING * 2}
				class="days"
			>
				<box
					css_classes={["row", "header"]}
					homogeneous
				// spacing={DEFAULT_SPACING * 2}
				>
					{WEEKDAY_LABELS.map((weekday_label) => (
						<label label={weekday_label} />
					))}
				</box>
				<For each={calendar_view((calendar_state: CalendarView) => calendar_state.weeks)}>
					{(week_cells: DayCell[]) => (
						<box
							css_classes={["row"]}
							homogeneous
						// spacing={DEFAULT_SPACING * 2}
						>
							{week_cells.map((day_cell: DayCell) => (
								<label
									class={day_cell.css_classes.join(" ")}
									label={day_cell.label}
									tooltipText={day_cell.tooltip_text}
								/>
							))}
						</box>
					)}
				</For>
			</box>
		</box>
	);
}

export function Events() {
	const [active_span, set_active_span] = createState<EventSpan>("today");
	const [visible_events, set_visible_events] = createState(new Array<CalendarEvent>());

	const update_visible_events = (events: CalendarEvent[], span: EventSpan) => {
		const { range_start, range_end } = range_for_span(span);
		const filtered = events
			.filter((event) => event_overlaps_range(event, range_start, range_end))
			.sort((a, b) => a.start.getTime() - b.start.getTime());
		set_visible_events(filtered);
	};

	ensure_events_loaded((events) => {
		update_visible_events(events, active_span.peek());
	});

	const on_refresh = () => {
		refresh_events().then((events) => {
			update_visible_events(events, active_span.peek());
		});
	};

	const on_select_span = (span: EventSpan) => {
		set_active_span(span);
		update_visible_events(events_state.peek(), span);
	};

	return (
		<box
			class="events"
			orientation={Gtk.Orientation.VERTICAL}
			spacing={DEFAULT_SPACING}
		// css_classes={["events"]}
		// margin={DEFAULT_SPACING * 2}
		// padding={DEFAULT_SPACING * 2}
		>
			{/* <label
				class="events-title"
				halign={Gtk.Align.START}
				xalign={0}
				label="Events"
			/> */}
			<box
				class="events-tabs"
				halign={Gtk.Align.START}
				spacing={DEFAULT_SPACING}
			>
				<button
					onClicked={() => on_select_span("today")}
					class={active_span.peek() === "today" ? "active" : ""}
					label="Today"
				/>
				<button
					onClicked={() => on_select_span("week")}
					class={active_span.peek() === "week" ? "active" : ""}
					label="Week"
				/>
				<button
					onClicked={() => on_select_span("month")}
					class={active_span.peek() === "month" ? "active" : ""}
					label="Month"
				/>
				<button
					onClicked={() => on_select_span("year")}
					class={active_span.peek() === "year" ? "active" : ""}
					label="Year"
				/>
			</box>
			<Gtk.ScrolledWindow
				css_classes={["events-scroll"]}
				vexpand={false}
				hexpand
				heightRequest={180}
				maxContentHeight={180}
			>
				<box
					class="events-list"
					orientation={Gtk.Orientation.VERTICAL}
					spacing={DEFAULT_SPACING}
				>
					<For each={visible_events}>
						{(event: CalendarEvent) => (
							<box
								class="event-item"
								orientation={Gtk.Orientation.VERTICAL}
								spacing={DEFAULT_SPACING / 2}
							>
								<label
									class="event-title"
									halign={Gtk.Align.START}
									xalign={0}
									label={event.title || "Untitled"}
								/>
								<label
									class="event-time"
									halign={Gtk.Align.START}
									xalign={0}
									label={format_event_time(event)}
								/>
								{event.description && (
									<label
										class="event-description"
										halign={Gtk.Align.START}
										xalign={0}
										wrap
										label={event.description}
									/>
								)}
							</box>
						)}
					</For>
					<box
						class="events-empty"
						visible={visible_events((items) => items.length === 0)}
					>
						<label
							halign={Gtk.Align.START}
							xalign={0}
							label="No events"
						/>
					</box>
				</box>
			</Gtk.ScrolledWindow>
			<box
				class="events-actions"
				spacing={DEFAULT_SPACING}
			>
				<button
					onClicked={on_refresh}
					label="Refresh"
				/>
				<button
					label="Add"
				/>
			</box>
		</box>
	)

}