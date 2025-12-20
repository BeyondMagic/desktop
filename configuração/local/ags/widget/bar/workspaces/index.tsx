import { hyprland } from "../../../services/hyprland";
import { createBinding, For } from "ags"
import { config } from "../../../app";
import Hyprland from "gi://AstalHyprland";
import { Workspace } from "./workspace";

type WorkspaceConfig = {
	monitor?: { id?: number };
	total?: number;
	labels?: { id: number; label: string }[];
};

const workspaceConfigs: WorkspaceConfig[] = Array.isArray(config.workspaces) ? config.workspaces : [];

export function Workspaces ( { monitor, length }: { monitor: number; length?: number } )
{
	const workspaces = createBinding(hyprland(), "workspaces")
	const workspaceConfig = workspaceConfigs.find(({ monitor: m }) => m?.id === monitor);
	const configuredLabels = workspaceConfig?.labels ?? [];
	const labelMap = new Map(configuredLabels.map(({ id, label }) => [id, label] as const));

	const configuredIds = configuredLabels.map(({ id }) => id);
	const count = length ?? workspaceConfig?.total ?? configuredIds.length;
	const baseIds = configuredIds.length > 0
		? (count > 0 ? configuredIds.slice(0, count) : configuredIds)
		: (count > 0 ? Array.from({ length: count }, (_, idx) => idx + 1) : []);

	const display = workspaces((existing) => {
		const raw: Hyprland.Workspace[] = Array.isArray(existing) ? existing : [];
		const actual = raw.filter((ws) => ws.id >= 0 && (monitor == null || ws.monitor?.id === monitor));

		if (baseIds.length === 0)
			return actual.map((ws) => ({ ws, fallbackLabel: labelMap.get(ws.id) }));

		const byId = new Map(actual.map((ws) => [ws.id, ws] as const));
		const seen = new Set<number>();
		const result: { ws: Hyprland.Workspace; fallbackLabel?: string }[] = [];

		for (const id of baseIds) {
			const ws = byId.get(id) ?? Hyprland.Workspace.dummy(id, null);
			result.push({ ws, fallbackLabel: labelMap.get(id) });
			seen.add(id);
		}

		for (const ws of actual) {
			if (!seen.has(ws.id))
			{
				result.push({ ws, fallbackLabel: labelMap.get(ws.id) });
			}
		}

		return result;
	})

	return <box class={"workspaces"}>
		<For each={display}>
			{({ ws, fallbackLabel }) => <Workspace ws={ws} fallbackLabel={fallbackLabel} />}
		</For>
	</box>;
}
