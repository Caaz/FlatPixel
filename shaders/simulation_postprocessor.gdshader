shader_type spatial;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;
uniform sampler2D NORMAL_TEXTURE : hint_normal_roughness_texture, filter_nearest;

uniform bool use_normal = false;
uniform bool use_color_quantization = false;

uniform sampler2D quantization_palette: source_color;

vec3 quantized_color(vec3 original_color){
	// Palette quantization
	ivec2 palette_size = textureSize(quantization_palette, 0);
	vec3 quantized_color = vec3(0.0, 1.0, 0.0); //bright debug-green color
	float min_dist = 9999.0;

	// Search through palette texture
	for (int y = 0; y < palette_size.y; y++) {
		for (int x = 0; x < palette_size.x; x++) {
			//get the color of the pixel at the center of each pixel rather than the corner.
			vec2 palette_uv = (vec2(float(x), float(y)) +0.5) / vec2(palette_size);
			vec3 palette_color = textureLod(quantization_palette, palette_uv, 0.0).rgb;
			float dist = distance(original_color, palette_color);
			if (dist < min_dist) {
				min_dist = dist;
				quantized_color = palette_color;
			}
		}
	}
	return quantized_color;
}

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	vec2 uv = UV * vec2(1, -1);
	if (use_normal) {
		ALBEDO = texture(NORMAL_TEXTURE, uv).rgb;
	} else if (use_color_quantization) {
		ALBEDO = quantized_color(texture(SCREEN_TEXTURE, uv).rgb);
	} else {
		ALBEDO = texture(SCREEN_TEXTURE, uv).rgb;
	}
	ALPHA = texture(SCREEN_TEXTURE, uv).a;
}
