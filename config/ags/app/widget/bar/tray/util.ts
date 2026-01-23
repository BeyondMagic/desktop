import GLib from "gi://GLib"
import Gio from "gi://Gio"

const ZERO_WIDTH_SPACE = "\u200B"

function make_unique_label(label: string, counts: Map<string, number>) {
	const count = counts.get(label) ?? 0
	counts.set(label, count + 1)
	if (count === 0)
		return label
	return `${label}${ZERO_WIDTH_SPACE.repeat(count)}`
}

export function clone_menu_model(model: Gio.MenuModel | null, counts = new Map<string, number>()): Gio.Menu {
	const menu = new Gio.Menu()
	if (!model)
		return menu

	const items = model.get_n_items()
	for (let index = 0; index < items; index++) {
		const section_link = model.get_item_link(index, "section")
		if (section_link) {
			const section_menu = clone_menu_model(section_link, counts)
			const section_label_variant = model.get_item_attribute_value(index, "label", null)
			const section_label = section_label_variant ? section_label_variant.deepUnpack() as string : null
			const unique_section_label = section_label ? make_unique_label(section_label, counts) : null
			menu.append_section(unique_section_label, section_menu)
			continue
		}

		const menu_item = Gio.MenuItem.new_from_model(model, index)
		const submenu_link = model.get_item_link(index, "submenu")

		if (submenu_link) {
			const label_variant = model.get_item_attribute_value(index, "label", null)
			const label = label_variant ? label_variant.deepUnpack() as string : null
			if (label) {
				const unique_label = make_unique_label(label, counts)
				menu_item.set_attribute_value("label", GLib.Variant.new_string(unique_label))
			}
			menu_item.set_submenu(clone_menu_model(submenu_link, counts))
		}

		menu.append_item(menu_item)
	}

	return menu
}