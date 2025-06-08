shader_type spatial;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;
uniform sampler2D NORMAL_TEXTURE : hint_normal_roughness_texture, filter_nearest;
uniform bool use_normal = false;

void vertex() {
	POSITION = vec4(VERTEX, 1.0);
}

void fragment() {
	vec2 uv = UV * vec2(1, -1);
	if (use_normal) {
		ALBEDO = texture(NORMAL_TEXTURE, uv).rgb;
	} else {
		ALBEDO = texture(SCREEN_TEXTURE, uv).rgb;
	}
	ALPHA = texture(SCREEN_TEXTURE, uv).a;
}
