import GLib from "gi://GLib";
import { Gtk } from "ags/gtk4"
import { For, createState, onCleanup } from "ags"
import { interval } from "ags/time"

type DayCell = {
	label: string;
	css_classes: string[];
}

type CalendarView = {
	base: GLib.DateTime;
	month_label: string;
	year_label: string;
	weeks: DayCell[][];
	is_current_month: boolean;
}

const WEEKDAY_LABELS = ["日", "月", "火", "水", "木", "金", "土"] as const;
const DEFAULT_SPACING = 6;

function ensure_date(year: number, month: number, day = 1) {
	const dt = GLib.DateTime.new_local(year, month, day, 0, 0, 0);
	return dt ?? GLib.DateTime.new_now_local();
}

function is_same_date(a: GLib.DateTime, b: GLib.DateTime) {
	return a.get_year() === b.get_year() &&
		a.get_month() === b.get_month() &&
		a.get_day_of_month() === b.get_day_of_month();
}

function build_weeks(first_day: GLib.DateTime): DayCell[][] {
	const today_date = GLib.DateTime.new_now_local();
	const month = first_day.get_month();
	const start_weekday = first_day.get_day_of_week() % 7;
	let cursor = first_day.add_days(-start_weekday) ?? first_day;
	const weeks: DayCell[][] = [];

	for (let week_index = 0; week_index < 6; week_index++) {
		const week_days: DayCell[] = [];

		for (let day_index = 0; day_index < 7; day_index++) {
			const is_current_month = cursor.get_month() === month;
			const classes = ["day"];

			if (!is_current_month)
				classes.push("inactive");

			if (is_same_date(cursor, today_date))
				classes.push("today");

			week_days.push({
				label: cursor.get_day_of_month().toString(),
				css_classes: classes,
			});

			cursor = cursor.add_days(1) ?? cursor;
		}

		weeks.push(week_days);
	}

	return weeks;
}

function is_same_month(a: GLib.DateTime, b: GLib.DateTime) {
	return a.get_year() === b.get_year() && a.get_month() === b.get_month();
}

function build_calendar_view(date: GLib.DateTime): CalendarView {
	const first_day = ensure_date(date.get_year(), date.get_month(), 1);
	const month_label = first_day.format("%B") ?? "Month";
	const year_label = first_day.format("%Y") ?? first_day.get_year().toString();
	const now = GLib.DateTime.new_now_local();

	return {
		base: first_day,
		month_label,
		year_label,
		weeks: build_weeks(first_day),
		is_current_month: is_same_month(first_day, now),
	};
}

export function Calendar() {
	const nav_arrows = {
		left: "◀",
		right: "▶",
	} as const;

	const [calendar_view, set_calendar_view] = createState(
		build_calendar_view(GLib.DateTime.new_now_local()),
	);

	const refresh_today_highlight = () => {
		print("Refreshing today's highlight");
		set_calendar_view((current_view: CalendarView) => {
			const now = GLib.DateTime.new_now_local();
			if (!current_view.is_current_month)
				return current_view;
			return build_calendar_view(now);
		});
	};

	const refresh_tick = interval(60_000, refresh_today_highlight);

	onCleanup(() => {
		refresh_tick?.cancel();
	});

	function shift_month(delta: number) {
		set_calendar_view((current_view: CalendarView) => {
			const next_base = current_view.base.add_months(delta);
			return build_calendar_view(next_base ?? current_view.base);
		});
	}

	function shift_year(delta: number) {
		set_calendar_view((current_view: CalendarView) => {
			const next_base = current_view.base.add_years(delta);
			return build_calendar_view(next_base ?? current_view.base);
		});
	}

	return (
		<box
			class="box"
			orientation={Gtk.Orientation.VERTICAL}
			spacing={DEFAULT_SPACING}
		>
			<box
				class="navigation"
				spacing={DEFAULT_SPACING * 2}
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
									css_classes={day_cell.css_classes}
									label={day_cell.label}
								/>
							))}
						</box>
					)}
				</For>
			</box>
		</box>
	);
}