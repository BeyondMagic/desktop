#version 300 es

precision mediump float;
in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;
uniform sampler2D tex;
uniform int wl_output;

// match_color.frag
void main() {
	if (wl_output == 1) {
		vec4 pixColor = texture(tex, v_texcoord);

		pixColor[0] *= 0.878; // Red
		pixColor[1] *= 0.986; // Green
		pixColor[2] *= 0.701; // Blue (Heavy reduction)

		fragColor = pixColor;
	} else {
		fragColor = texture(tex, v_texcoord);
	}
}
