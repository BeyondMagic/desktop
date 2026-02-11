import { execAsync } from "ags/process";

export async function events({
	time_min,
	time_max
}: {
	time_min: string;
	time_max: string;
}) {

	const stdout = await execAsync([
		"calendar.nu",
		"main",
		"events",
		"--time-min", time_min,
		"--time-max", time_max,
		"--json=true"
	]);

	const events = JSON.parse(stdout);

	return events.map((event: any) => ({
		title: event.summary,
		start: new Date(event.start),
		end: new Date(event.end),
		id: event.id,
		type: event.event_type
	}));
}

export const google = {
	events
}