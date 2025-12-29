import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4";
import { Horizontal, Vertical, drawing_area } from "./math";
import { onCleanup } from "ags";

export function Corner ({vertical, horizontal, monitor}: {vertical: Vertical, horizontal: Horizontal, monitor: number})
{
    const vertical_anchor = vertical === 'top' ? Astal.WindowAnchor.TOP : Astal.WindowAnchor.BOTTOM;
    const horizontal_anchor = horizontal === 'left' ? Astal.WindowAnchor.LEFT : Astal.WindowAnchor.RIGHT;

    return <window
            name={`corner-${vertical}-${horizontal}`}
            cssClasses={['corner', vertical, horizontal]}
            monitor={monitor}
            anchor={vertical_anchor | horizontal_anchor}
            application={app}
            // BACKGROUND: makes impossible to interact if a window is maximized, although appears behind transparent windows
            // TOP: makes possible to interact if a window is maximized, although disappears behind transparent windows
            // FIXME: is it possible to have TOP's interaction with maximized windows and still appear above transparent windows?
            layer={Astal.Layer.TOP}
            visible
            $={(self) => onCleanup(() => self.destroy())}
        >
            {drawing_area(vertical, horizontal)}
    </window>
};

export {
	Vertical,
	Horizontal,	
}