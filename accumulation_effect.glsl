#[compute]
#version 450

// Invocations in the (x, y, z) dimension
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(rgba16f, set = 0, binding = 0) uniform restrict writeonly image2D output_buffer;

layout(rgba16f, set = 0, binding = 1) uniform image2D accumulation_buffer;

layout(set = 0, binding = 2) uniform sampler2D frame_texture;

// Our push constant
layout(push_constant, std430) uniform Params {
	vec2 raster_size;
	float blur_strength;
	float distance_factor;
} params;

// The code we want to execute in each invocation
void main() {
	
	ivec2 uv = ivec2(gl_GlobalInvocationID.xy);
	ivec2 size = ivec2(params.raster_size);

	// Prevent reading/writing out of bounds.
	if (uv.x >= size.x || uv.y >= size.y) {
		return;
	}

	vec4 frame_color = texture(frame_texture, vec2(uv + 0.5)/vec2(size));

	vec4 acc_color = imageLoad(accumulation_buffer, uv);

	float delta = clamp(pow(params.blur_strength, params.distance_factor), 0.0, 1.0);

	vec4 acc_blend = mix(frame_color, acc_color, delta);

	imageStore(accumulation_buffer, uv, acc_blend);

	imageStore(output_buffer, uv, acc_blend);

}
