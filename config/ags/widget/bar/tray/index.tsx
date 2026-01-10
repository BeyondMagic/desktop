import { For, createBinding, onCleanup } from "ags"
import AstalTray from "gi://AstalTray"
import { Gtk } from "ags/gtk4"
import { clone_menu_model } from "./util"

export function Tray() {

	const tray = AstalTray.get_default()
	const items = createBinding(tray, "items")

	const setup_item = (btn: Gtk.MenuButton, item: AstalTray.TrayItem) => {
		const update_menu_model = () => {
			try {
				btn.menuModel = clone_menu_model(item.menuModel)
			} catch (error) {
				print(`Failed to clone menu model for tray item: ${error}`)
			}
		}

		update_menu_model()

		btn.insert_action_group("dbusmenu", item.actionGroup)

		// update on action-group changes
		const conn = item.connect("notify::action-group", () => {
			btn.insert_action_group("dbusmenu", item.actionGroup)
		})
		const menu_conn = item.connect("notify::menu-model", update_menu_model)

		// ensure we cleanup when this menubutton unmounts
		onCleanup(() => {
			try { item.disconnect(conn) } catch { }
			try { item.disconnect(menu_conn) } catch { }
			try { btn.insert_action_group("dbusmenu", null) } catch { }
			try { (btn as any).set_menu_model?.(null) ?? (btn.menuModel = null as any) } catch { }
		})
	}

	const trays = (
		<box
			class={'items'}
			spacing={4}
		>
			<For each={items}>
				{(item) => (
					<menubutton
						$={(self) => setup_item(self, item)}
					>
						<image gicon={createBinding(item, "gicon")} />
					</menubutton>
				)}
			</For>
		</box>
	)

	// Create and configure the popover
	const popover = new Gtk.Popover();
	popover.set_position(Gtk.PositionType.BOTTOM);
	popover.set_child(trays as any);

	let arrow_image: Gtk.Image;

	// Connect to popover visibility changes
	popover.connect("notify::visible", () => {
		if (arrow_image) {
			arrow_image.set_from_icon_name(
				popover.visible ? "arrow-up-symbolic" : "arrow-down-symbolic"
			);
		}
	});

	return (
		<menubutton
			class="tray-button"
			$={self => self.set_popover(popover)}
		>
			<image
				class="icon"
				icon_name="arrow-down-symbolic"
				$={self => arrow_image = self}
			/>
		</menubutton>
	)
}