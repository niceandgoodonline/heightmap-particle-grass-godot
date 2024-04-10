shader_type particles;

group_uniforms instancing;
uniform int instance_rows;
uniform float instance_spacing;
uniform float density_adjust;
uniform vec3 InstanceOffset = vec3(0.0, 0.0, 0.0);

group_uniforms randomization;
uniform float randomOffset: hint_range(0.0, 1.0, 0.001) = 0.0;
uniform float random_spacing;
uniform vec3 min_scale = vec3(1.0);
uniform vec3 max_scale = vec3(1.0);

uniform bool testRotation = true;
uniform bool orient_to_normal = true;
uniform bool orient_up_with_normal = true;

group_uniforms maps;
uniform sampler2D heightmap:  repeat_disable;
uniform sampler2D heightmap_normals:  repeat_disable;
uniform sampler2D foliage_map:  repeat_disable;
uniform float heightmap_scale = 1.0;
uniform float heightmap_height_scale = 1.0;

render_mode disable_velocity, disable_force;

vec3 unpack_normal(vec4 rgba) {
	vec3 n = rgba.xzy * 2.0 - vec3(1.0);
	n.z *= -1.0;
	return normalize(n);
}

float random (vec2 uv) {
    float rf = fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * (43758.5453123 + randomOffset));
	
	return rf;
}

mat4 rotate_y(float theta) {
    return mat4(vec4(cos(theta), 0, -sin(theta), 0), vec4(0, 1, 0, 0), vec4(sin(theta), 0, cos(theta), 0), vec4(0, 0, 0, 1));
}

void start() {
	//create a grid
	vec3 pos = vec3(0.0, 0.0, 0.0);
	pos.z = float(INDEX);
	pos.x = mod(pos.z, float(instance_rows));
	pos.z = (pos.z - pos.x) / float(instance_rows);
	
	// center the grid on the emitter
	pos.x -= float(instance_rows) * 0.5;
	pos.z -= float(instance_rows) * 0.5;
	
	// widen the grid
	pos *= instance_spacing;
	
	// make the grid space local to the emitter space
	pos.x += EMISSION_TRANSFORM[3][0] - mod(EMISSION_TRANSFORM[3][0], instance_spacing);
	pos.z += EMISSION_TRANSFORM[3][2] - mod(EMISSION_TRANSFORM[3][2], instance_spacing);
	
	//create a random value per-instance
	vec3 r = vec3(random(pos.xz), random(pos.xz + vec2(0.5)), random(pos.xz - vec2(0.5)));
	
	//add some randomness to the instance spacing
	pos.x += ((r.x * 2.0) - 1.0) * random_spacing;
	pos.z += ((r.y * 2.0) - 1.0) * random_spacing;
	
	// map world space to heightmap space
	float pixel_size = 1.0 / float(textureSize(heightmap, 0).x);
	vec2 half_pixel_offset = vec2(pixel_size, pixel_size) / 2.0;
	float heightmap_size = float(textureSize(heightmap, 0).x);
	vec2 world_map_uv = pos.xz * (1.0 / (heightmap_scale * heightmap_size)) + vec2(0.5) + half_pixel_offset;
	
	// set the height according to the heightmap data
	pos.y = texture(heightmap, world_map_uv).r * heightmap_height_scale;
	
	// hash the density using the density texture
	vec4 density = texture(foliage_map, world_map_uv);
	if (density.r > density.g) {
		pos.y = -10000.0;
	} else if (density.b > density.g) {
		pos.y = -10000.0;
	}
	
	// ROTATION BULLSHIT COMMENCES
	// set the base transform (no rotation, facing up)
	TRANSFORM[0].xyz = vec3(1.0, 0.0, 0.0);
	TRANSFORM[1].xyz = vec3(0.0, 1.0, 0.0);
	TRANSFORM[2].xyz = vec3(0.0, 0.0, 1.0);

	vec3 rotation_x = vec3(1.0);
	vec3 rotation_z = vec3(1.0);
	rotation_x.x = cos(r.x * TAU);
	rotation_x.z = -sin(r.x * TAU);
	rotation_z.x = sin(r.x * TAU);
	rotation_z.z = cos(r.x * TAU);

	vec3 normal_dir = unpack_normal(texture(heightmap_normals, world_map_uv));
	vec3 normal_align_y = normalize(normal_dir);
	vec3 normal_align_z = normalize(cross(normal_align_y, vec3(0.0, 1.0, 0.0)));
	vec3 normal_align_x = normalize(cross(normal_dir, normal_align_z));
	
	mat3 normal_align_matrix = mat3(normal_align_x, normal_align_y, normal_align_z);
	
	// randomized rotation and normal oriented rotations fight, so we cant use em simultaneously
	if (orient_to_normal) {
		TRANSFORM[0].xyz = normal_align_matrix[0];
		TRANSFORM[1].xyz = normal_align_matrix[1];
		TRANSFORM[2].xyz = normal_align_matrix[2];
		if (orient_up_with_normal)
		{
			TRANSFORM[1].xyz = vec3(0.0,1.0,0.0);
		}
		// if (length(normal_align_matrix[0]) >= 1.0 || length(normal_align_matrix[1]) >= 1.0 || length(normal_align_matrix[2]) >= 1.0) {
		// 	pos.y += VerticalOffset;
		// }
	}
	else {
		TRANSFORM[0].x = rotation_x.x;
		TRANSFORM[0].z = rotation_x.z;
		TRANSFORM[2].x = rotation_z.x;
		TRANSFORM[2].z = rotation_z.z;
	}

	// calculate and apply the scale after rotating
	vec3 scale = vec3(mix(min_scale.x, max_scale.x, r.x), mix(min_scale.y, max_scale.y, r.y), mix(min_scale.z, max_scale.z, r.z));
	
	TRANSFORM[0] *= scale.x;
	TRANSFORM[1] *= scale.y;
	TRANSFORM[2] *= scale.z;
	
	// apply the position
	TRANSFORM[3].xyz = pos.xyz + InstanceOffset;
}