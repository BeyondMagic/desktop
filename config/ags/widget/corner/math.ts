import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4";
import Cairo from "cairo";
import config from "../../config.json";

const radius = config.corner;
	
export type Vertical = 'top' | 'bottom';
export type Horizontal = 'left' | 'right';

export function drawing_area (vertical: Vertical, horizontal: Horizontal)
{
	const drawing = new Gtk.DrawingArea();
	drawing.set_size_request(radius, radius);

	drawing.set_draw_func((_, cr) => {
		const context = cr as Cairo.Context;
		
		// Determine the center coordinates based on orientation
		const center = {
			x: horizontal === 'left' ? radius : 0,
			y: vertical === 'top' ? radius : 0
		}
		
		// Determine the angles based on orientation
		let angle = {
			start: 0,
			end: 0
		}
		if (vertical === 'top') {
			if (horizontal === 'left') {
				angle.start = Math.PI;
				angle.end = 3 * Math.PI / 2;
			} else {
				angle.start = 3 * Math.PI / 2;
				angle.end = 2 * Math.PI;
			}
		} else {
			if (horizontal === 'left') {
				angle.start = Math.PI / 2;
				angle.end = Math.PI;
			} else {
				angle.start = 0;
				angle.end = Math.PI / 2;
			}
		}
		
		// Determine the line endpoint
		const line = {
			x: horizontal === 'left' ? 0 : radius,
			y: vertical === 'top' ? 0 : radius
		}
		
		// Draw the corner
		context.arc(center.x, center.y, radius, angle.start, angle.end);
		context.lineTo(line.x, line.y);
		context.closePath();
		context.setSourceRGBA(
			config.background_color.red / 255,
			config.background_color.green / 255,
			config.background_color.blue / 255,
			config.background_color.alpha
		);
		context.fill();
	});
	return drawing;
}