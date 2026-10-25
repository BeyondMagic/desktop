// Color interpolation utility for battery percentage visualization

export type RGBAColor = {
    r: number;
    g: number;
    b: number;
    a: number;
}

/**
 * Converts a HEX color string to RGBA object
 * @param hex - HEX color in format '#RRGGBBAA' or '#RRGGBB'
 */
function hex_to_rgba(hex: string): RGBAColor {
    // Remove the # if present
    hex = hex.replace('#', '');
    
    // Handle 6-digit hex (RGB) by adding full alpha
    if (hex.length === 6) {
        hex += 'FF';
    }
    
    // Handle 8-digit hex (RGBA)
    if (hex.length === 8) {
        return {
            r: parseInt(hex.substring(0, 2), 16),
            g: parseInt(hex.substring(2, 4), 16),
            b: parseInt(hex.substring(4, 6), 16),
            a: parseInt(hex.substring(6, 8), 16)
        };
    }
    
    throw new Error(`Invalid hex color format: ${hex}`);
}

/**
 * Converts RGBA object to HEX string
 * @param rgba - RGBA color object
 */
function rgba_to_hex(rgba: RGBAColor): string {
    const to_hex = (n: number) => Math.round(Math.max(0, Math.min(255, n))).toString(16).padStart(2, '0');
    return `#${to_hex(rgba.r)}${to_hex(rgba.g)}${to_hex(rgba.b)}${to_hex(rgba.a)}`;
}

/**
 * Linear interpolation between two numbers
 * @param start - Start value
 * @param end - End value  
 * @param factor - Interpolation factor (0-1)
 */
function lerp(start: number, end: number, factor: number): number {
    return start + (end - start) * factor;
}

/**
 * Interpolates between two RGBA colors
 * @param color1 - First color
 * @param color2 - Second color
 * @param factor - Interpolation factor (0-1)
 */
function interpolate(color1: RGBAColor, color2: RGBAColor, factor: number): RGBAColor {
    return {
        r: lerp(color1.r, color2.r, factor),
        g: lerp(color1.g, color2.g, factor),
        b: lerp(color1.b, color2.b, factor),
        a: lerp(color1.a, color2.a, factor)
    };
}

/**
 * Creates a color gradient and returns the color at a specific percentage
 * @param hex_colors - Array of HEX color strings
 * @param percentage - Percentage value (0-100)
 * @returns HEX color string at the given percentage
 */
export function get_color_at_percentage(hex_colors: string[], percentage: number): string {
    if (hex_colors.length === 0) {
        throw new Error("At least one color must be provided");
    }
    
    if (hex_colors.length === 1) {
        return hex_colors[0]!;
    }
    
    // Clamp percentage to 0-100 range
    percentage = Math.max(0, Math.min(100, percentage));
    
    // Convert hex colors to RGBA
    const rgba_colors = hex_colors.map(hex_to_rgba);
    
    // If percentage is 0, return first color
    if (percentage === 0) {
        return rgba_to_hex(rgba_colors[0]!);
    }
    
    // If percentage is 100, return last color
    if (percentage === 100) {
        return rgba_to_hex(rgba_colors[rgba_colors.length - 1]!);
    }
    
    // Calculate which segment we're in and the position within that segment
    const segment_size = 100 / (rgba_colors.length - 1);
    const segment_index = Math.floor(percentage / segment_size);
    const segment_progress = (percentage % segment_size) / segment_size;
    
    // Handle edge case where we're exactly at the last segment
    if (segment_index >= rgba_colors.length - 1) {
        return rgba_to_hex(rgba_colors[rgba_colors.length - 1]!);
    }
    
    // Interpolate between the two colors in this segment
    const color1 = rgba_colors[segment_index]!;
    const color2 = rgba_colors[segment_index + 1]!;
    const interpolated_color = interpolate(color1, color2, segment_progress);
    
    return rgba_to_hex(interpolated_color);
}

/**
 * Generates an array of HEX colors representing the full gradient
 * @param hex_colors - Array of HEX color strings
 * @param steps - Number of steps in the gradient (default: 101 for 0-100%)
 * @returns Array of HEX color strings
 */
export function generate_colors_gradient(hex_colors: string[], steps: number = 101): string[] {
    const gradient: string[] = [];
    
    for (let i = 0; i < steps; i++) {
        const percentage = (i / (steps - 1)) * 100;
        gradient.push(get_color_at_percentage(hex_colors, percentage));
    }
    
    return gradient;
}
