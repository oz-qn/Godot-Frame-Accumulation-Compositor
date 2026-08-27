#[compute]
#version 450

// Invocations in the (x, y, z) dimension
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(rgba16f, set = 0, binding = 0) uniform image2D output_buffer;

layout(rgba16f, set = 0, binding = 1) uniform image2D accumulation_buffer;

// Our push constant
layout(push_constant, std430) uniform Params {
	float delta;
} params;

// The code we want to execute in each invocation
void main() {
	ivec2 uv = ivec2(gl_GlobalInvocationID.xy);
	vec4 frame_color = imageLoad(output_buffer, uv);
	vec4 acc_color = imageLoad(accumulation_buffer, uv);
	vec4 acc_blend = mix(frame_color, acc_color, params.delta);
	imageStore(accumulation_buffer, uv, acc_blend);
	imageStore(output_buffer, uv, acc_blend);
}
