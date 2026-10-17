shader_type canvas_item;
render_mode unshaded;

// Arcade CRT look: barrel distortion, scanlines, chromatic aberration, vignette.

uniform bool enabled = true;
uniform float curvature : hint_range(0.0, 0.5) = 0.12;
uniform float scanline_strength : hint_range(0.0, 1.0) = 0.35;
uniform float aberration : hint_range(0.0, 4.0) = 1.2;
uniform float vignette_strength : hint_range(0.0, 2.0) = 0.9;
uniform float brightness : hint_range(0.5, 2.0) = 1.25;
uniform vec4 screen_tint : source_color = vec4(0.92, 1.0, 0.94, 1.0);

vec2 barrel(vec2 uv, float k) {
	vec2 c = uv * 2.0 - 1.0;
	float r2 = dot(c, c);
	c *= 1.0 + k * r2;
	return c * 0.5 + 0.5;
}

void fragment() {
	vec2 uv = UV;
	if (!enabled) {
		COLOR = texture(TEXTURE, uv) * screen_tint;
		return;
	}

	uv = barrel(uv, curvature);
	vec2 edge = smoothstep(vec2(0.0), vec2(0.02), uv) * smoothstep(vec2(0.0), vec2(0.02), 1.0 - uv);
	float mask = edge.x * edge.y;

	vec2 px = TEXTURE_PIXEL_SIZE * aberration;
	float r = texture(TEXTURE, uv + vec2(px.x, 0.0)).r;
	float g = texture(TEXTURE, uv).g;
	float b = texture(TEXTURE, uv - vec2(px.x, 0.0)).b;
	vec3 col = vec3(r, g, b);

	float line = sin(uv.y / TEXTURE_PIXEL_SIZE.y * 3.14159);
	col *= 1.0 - scanline_strength * 0.5 * (1.0 - line);

	vec2 vc = uv * 2.0 - 1.0;
	col *= 1.0 - vignette_strength * dot(vc, vc) * 0.35;

	col *= brightness * screen_tint.rgb;
	COLOR = vec4(col * mask, 1.0);
}
