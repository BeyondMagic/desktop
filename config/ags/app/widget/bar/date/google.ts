import { execAsync } from "ags/process";

export async function events({
	time_min,
	time_max,
	calendar = "primary"
}: {
	time_min: string;
	time_max: string;
	calendar?: string;
}) {

	const stdout = await execAsync([
		"calendar3.nu",
		"events",
		"--calendar", calendar,
		"--time-min", time_min,
		"--time-max", time_max,
		"--json=true"
	]);

	const events = JSON.parse(stdout);

	return events.map((event: any) => ({
		title: event.summary,
		description: event.description,
		start: new Date(event.start),
		end: new Date(event.end),
		id: event.id,
		type: event.event_type
	}));
}

export const google = {
	events
}