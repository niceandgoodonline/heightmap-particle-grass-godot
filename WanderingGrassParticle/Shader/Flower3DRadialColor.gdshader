shader_type spatial;
render_mode blend_mix, depth_prepass_alpha, cull_back, diffuse_toon, specular_toon;

group_uniforms Texture;
uniform vec4 CentreColor : source_color = vec4(0.141176, 0.156863, 0.074510, 1.000000);
uniform vec4 PetalColor : source_color = vec4(0.384314, 0.529412, 0.301961, 1.000000);

uniform float size: hint_range(0.0, 3.0, 0.01) = 1.15;
uniform float width: hint_range(0.0, 3.0, 0.01) = 1.15;
uniform vec2 centre = vec2(0.5);

uniform sampler2D FlowerTexture;
uniform float AlphaThreshold: hint_range(0.0, 1.0, 0.01) = 0.5;


uniform float Metallic: hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float Roughness: hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float Specular: hint_range(0.0, 1.0, 0.01) = 0.0;



group_uniforms Vertex;
uniform sampler2D WindNoise;

uniform float WindRate    : hint_range(-10.0, 10.0, 0.01) = 0.1;
uniform float WindStrength: hint_range(-10.0, 10.0, 0.01) = 0.1;

uniform vec3 PlayerPosition = vec3(0.0);
uniform float interact_power : hint_range(-5.0, 5.0, 0.01) = 0.5;
uniform float radius : hint_range(-5.0, 5.0, 0.01) = .5;

void vertex() {
	vec3 world_vert = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; // model space to world space
	vec4 wind_tex   = texture(WindNoise, UV + world_vert.xy + TIME * WindRate * 0.1);
	vec3 direction  = world_vert - PlayerPosition;
	direction.xz    *= 0.2;
	direction       = normalize(direction);
	float dist      = distance(PlayerPosition, world_vert);
	float power     = smoothstep(radius, 0.0, dist);
	direction       = (vec4(direction, 1.0) * MODEL_MATRIX).xyz; // world space direction to model space
	VERTEX          += direction * power * interact_power * (1.0 - UV.y);
	VERTEX          += vec3(wind_tex.xyz) * vec3(1.0 - UV.y) * WindStrength * 0.1;
}

void fragment() {
	float d = distance(UV, centre);
	float h = size;
	float l = h - (width);
	ALBEDO = mix(CentreColor, PetalColor, smoothstep(l, h, d)).rgb;

	ALPHA                   = texture(FlowerTexture, UV).a;
	ALPHA_SCISSOR_THRESHOLD = AlphaThreshold;
	METALLIC                = Metallic;
	ROUGHNESS               = Roughness;
	SPECULAR                = Specular;
}