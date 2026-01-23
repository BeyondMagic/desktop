import { createBinding, With } from "ags"
import { focused_client } from "../../../services/hyprland"
import { config } from "../../../app"


export function Label ()
{
	   return <With
		   $type='end'
		   value={focused_client()}
	   >
		{client => {
			const client_title = createBinding(client, "title");

			return <label
				$type='end'
				css_classes={[
					"title"
				]}
				label={client && client_title(title => title ?? "")}
			/>
		}}
	</With>
}