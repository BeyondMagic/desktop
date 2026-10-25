import GLib from "gi://GLib";
import { Gtk } from "ags/gtk4"
import { With, For, createState, onCleanup } from "ags"
import { interval, timeout } from "ags/time"

import {
	type CalendarView, type CalendarEvent, type DayCell, type EventSpan,
	events_state, refresh_events, ensure_events_loaded,
	build_calendar_view, range_for_span, event_overlaps_range,
	format_event_time, WEEKDAY_LABELS, DEFAULT_SPACING,
	REFRESH_RATE, REFRESH_RATE_FIRST,
	set_refresh_calendar_view,
} from "../../../services/calendar"

export function Calendar() {
	const nav_arrows = {
		left: "◀",
		right: "▶",
	} as const;

	const [calendar_view, set_calendar_view] = createState(
		build_calendar_view(GLib.DateTime.new_now_local(), events_state.peek()),
	);

	set_refresh_calendar_view(() => {
		set_calendar_view((current_view: CalendarView) =>
			build_calendar_view(current_view.base, events_state.peek()),
		);
	});

	const refresh_today_highlight = () => {
		set_calendar_view((current_view: CalendarView) => {
			const now = GLib.DateTime.new_now_local();
			if (!current_view.is_current_month)
				return current_view;
			return build_calendar_view(now, events_state.peek());
		});
	};

	const refresh_tick = interval(REFRESH_RATE, refresh_today_highlight);
	timeout(REFRESH_RATE_FIRST, refresh_today_highlight);

	onCleanup(() => {
		refresh_tick?.cancel();
		set_refresh_calendar_view(null);
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
				class="days"
			>
				<box
					css_classes={["row", "header"]}
					homogeneous
				>
					{WEEKDAY_LABELS.map((weekday_label) => (
						<label css_classes={[
							weekday_label.weekday ? "weekday" : ""
						]} label={weekday_label.label} />
					))}
				</box>
				<For each={calendar_view((calendar_state: CalendarView) => calendar_state.weeks)}>
					{(week_cells: DayCell[]) => (
						<box
							css_classes={["row"]}
							homogeneous
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
		>
			<box>
				<With value={active_span}>
					{(span) => (
						<box
							class="events-tabs"
							halign={Gtk.Align.START}
							spacing={DEFAULT_SPACING}
						>
							<button
								onClicked={() => on_select_span("today")}
								class={span === "today" ? "active" : ""}
								label="Today"
								$={(self) => {
									self.set_cursor_from_name("pointer");
								}}
							/>
							<button
								onClicked={() => on_select_span("week")}
								class={span === "week" ? "active" : ""}
								label="Week"
								$={(self) => {
									self.set_cursor_from_name("pointer");
								}}
							/>
							<button
								onClicked={() => on_select_span("month")}
								class={span === "month" ? "active" : ""}
								label="Month"
								$={(self) => {
									self.set_cursor_from_name("pointer");
								}}
							/>
							<button
								onClicked={() => on_select_span("year")}
								class={span === "year" ? "active" : ""}
								label="Year"
								$={(self) => {
									self.set_cursor_from_name("pointer");
								}}
							/>
						</box>
					)}
				</With>
			</box>
			<Gtk.ScrolledWindow
				css_classes={["events-scroll"]}
				vexpand={false}
				hexpand
				heightRequest={200}
				maxContentHeight={200}
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
					class="action refresh"
					onClicked={on_refresh}
					label="Refresh"
					$={(self) => {
						self.set_cursor_from_name("pointer");
					}}
				/>
				<button
					class="action add"
					label="Add"
					$={(self) => {
						self.set_cursor_from_name("pointer");
					}}
				/>
			</box>
		</box>
	)
}