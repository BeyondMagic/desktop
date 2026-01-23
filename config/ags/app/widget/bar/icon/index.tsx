import { createBinding, createComputed, With } from "ags"
import { focused_client } from "../../../services/hyprland"
import { config } from "../../../app"
import { resolveCategory } from "./map"

const FALLBACK_ICON = "unknown-status-symbolic";

export function Icon() {
	return <box>
		<With
			value={focused_client()}
		>
			{client => {
				if (!client)
					return <image
						width_request={config.corner}
						height_request={config.corner}
						css_classes={["icon"]}
					/>

				const client_class = createBinding(client, "class");
				const client_title = createBinding(client, "initial_title");
				const icon_name = createComputed([client_class, client_title], (class_name, title) => {
					const category = resolveCategory({ className: class_name, title });
					if (!category) {
						if (class_name)
							printerr("No category found for class:", class_name);
						if (title)
							printerr("No category found for title:", title);
					}
					return category ?? FALLBACK_ICON;
				});

				return <image
					width_request={config.corner}
					height_request={config.corner}
					css_classes={[
						"icon"
					]}
					icon_name={icon_name}
				/>
			}}
		</With>
	</box>
}