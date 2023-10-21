// Starfield shader v5 by Brian Smith (steampunkdemon.itch.io)
// MIT licence

shader_type canvas_item;

uniform float opacity = 1.0;

// Comment out the following line if you are not applying the shader to a ColorRect:
uniform vec2 dimensions = vec2(1024.0, 600.0); // Resolution of ColorRect in pixels

uniform float small_stars = 100.0; // Number of small stars. Rows for horizontally scrolling stars or columns for vertically scrolling stars.
uniform float small_stars_far_size : hint_range(0.1, 1.0, 0.1) = 0.5;
uniform float small_stars_near_size : hint_range(0.1, 1.0, 0.1) = 1.0;

// Replace the below references to 'source_color' with 'hint_color' if you are using a version of Godot before 4.0.
uniform vec4 far_stars_color : source_color = vec4(0.50, 0.0, 1.0, 1.0);
uniform vec4 near_stars_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

uniform float base_scroll_speed : hint_range(0.0, 1.0, 0.01) = 0.05;
uniform float additional_scroll_speed : hint_range(0.01, 1.0, 0.01) = 0.05;

void fragment() {
// The below line will scroll the stars from right to left or from bottom to top.
// To make the stars scroll in the opposite direction change the line to:

// You can then update the time uniform from your _physics_process function by adding or subtracting delta. You can also pause the scrolling by not changing the time uniform.
	float time = 10000.0 + TIME;

// Horizontal scrolling:
	float small_star_rn = fract(sin(floor(UV.y * small_stars)) * dimensions.y);
	vec2 small_star_uv = vec2(fract(UV.x + (base_scroll_speed + small_star_rn * additional_scroll_speed) * time) * small_stars * dimensions.x / dimensions.y, fract(UV.y * small_stars)) * 2.0 - 1.0;

	vec4 star_color = mix(far_stars_color, near_stars_color, small_star_rn);
	float star_size = small_stars_far_size + (small_stars_near_size - small_stars_far_size) * small_star_rn;

// Render small stars as circles with soft edges:
	COLOR.rgb = mix(COLOR.rgb, star_color.rgb, max((star_size - length(small_star_uv)) / star_size, 0.0) * star_color.a);
	
	COLOR.a = COLOR.a - (COLOR.a - opacity);
}