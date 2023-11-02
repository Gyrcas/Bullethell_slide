shader_type canvas_item;

uniform float wave_count : hint_range(1.0, 20.0, 1.0) = 20.0;
uniform float speed : hint_range(0.0, 10.0, 0.1) = 3.0;
uniform float height : hint_range(0.0, 0.1, 0.001) = 0.005;

uniform vec2 r_displacement = vec2(3.0, 0.0);
uniform vec2 g_displacement = vec2(0.0, 0.0);
uniform vec2 b_displacement = vec2(-3.0, 0.0);

uniform float shader_time = 0;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec2 cPos = -1.0 + 2.0 * UV / (1.0 / TEXTURE_PIXEL_SIZE);
	float cLength = length(cPos);
	vec2 uv = FRAGCOORD.xy / (1.0 / SCREEN_PIXEL_SIZE).xy + (cPos/cLength) * cos(cLength * wave_count - shader_time * speed) * height;
	float r = texture(SCREEN_TEXTURE, uv + vec2(SCREEN_PIXEL_SIZE*r_displacement) * sin(shader_time) * 2.0, 0.0).r;
	float g = texture(SCREEN_TEXTURE, uv + vec2(SCREEN_PIXEL_SIZE*g_displacement) * sin(shader_time) * 2.0, 0.0).g;
	float b = texture(SCREEN_TEXTURE, uv + vec2(SCREEN_PIXEL_SIZE*b_displacement) * sin(shader_time) * 2.0, 0.0).b;
	COLOR = vec4(r,g,b,1.0);
}