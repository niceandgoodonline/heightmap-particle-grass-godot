shader_type spatial;
render_mode blend_mix, cull_disabled, diffuse_toon, specular_toon;

group_uniforms Color;
uniform float ColorRampOffset  : hint_range(-1.0, 1.0, 0.01) = 0.0;
uniform vec4 BaseColor         : source_color = vec4(0.28, 0.55, 0.2, 1.0);
uniform vec4 TopColor          : source_color = vec4(0.67, 0.89, 0.16, 1.0);
uniform vec4 WindColor         : source_color = vec4(0.67, 0.89, 0.16, 1.0);
uniform float WindColorStrength: hint_range(-1.0, 1.0, 0.001) = 0.2;
uniform float GlobalWindVariationStrength : hint_range(0.0, 1.0, 0.001) = 0.1;

group_uniforms GlobalWind;
uniform float GlobalHorizontalDisplacementDamp	  : hint_range(-2.0, 2.0, 0.001) = 0.1;
uniform float GlobalVerticalDisplacementDamp: hint_range(-2.0, 2.0, 0.001) = 0.1;
uniform float GlobalWindPowerDamp               : hint_range(0.0, 1.0, 0.001) = 0.0;
uniform vec2 WindDirection                = vec2(0.1, 1.0);
uniform vec2 GlobalWindUVTiling           = vec2(1.0, 1.0);
uniform float GlobalWindSpeed             : hint_range(-10.0, 10.0, 0.001) = 0.1;
uniform float GlobalWindSpeedMagnitude    : hint_range(-1.0, 1.0, 0.001) = 0.01;
uniform float GlobalWindStrength          : hint_range(-10.0, 10.0, 0.001) = 0.1;
// uniform float WindStrengthMagnitude       : hint_range(-1.0, 1.0, 0.001) = 0.1;
uniform vec2 GlobalWindVariationDirection = vec2(-1, 1.0);
uniform vec2 GlobalWindVariationUVTiling  = vec2(1.0, 1.0);

uniform sampler2D GlobalWindNoise;
uniform sampler2D WindVariationNoise;

group_uniforms LocalWind;
uniform float LocalWindRate    : hint_range(-10.0, 10.0, 0.001) = 1.25;
uniform float LocalWindStrength: hint_range(-2.0, 2.0, 0.001) = 0.1;

group_uniforms PlayerDisplacement;
uniform vec3 PlayerPosition = vec3(0.0);
uniform vec2 fadeOffset = vec2(0.0, 3.0);  // position of the camera, needs to be updated by script each frame, this is the default start pos
uniform vec2 particleSystemOffset = vec2(0.0, 0.0);
uniform float PlayerDisplacementAmount = 2;
uniform float PlayerRadius             = 3;
uniform float PlayerDisplacementMulitplierY: hint_range(-5.0, 20.0, 0.001) = 3.0;
uniform float PlayerDisplacementMulitplierXZ: hint_range(-5.0, 20.0, 0.001) = 1.0;

varying float wind_power;

varying float squishAtDistance;

void vertex() {
	vec3 world                = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float wind_time_offset    = TIME * LocalWindRate;
	vec2 wind_direction       = normalize(WindDirection);
	vec4 wind_variation       = texture(WindVariationNoise, GlobalWindVariationUVTiling * UV + TIME * 0.01 * GlobalWindVariationDirection);
	vec4 global_wind          = texture(GlobalWindNoise, GlobalWindUVTiling * 0.1 * world.xz + TIME * GlobalWindSpeed * wind_direction * GlobalWindSpeedMagnitude + TIME * 0.01 * wind_direction);
	wind_power                = clamp(global_wind.x * wind_variation.x * GlobalWindVariationStrength, 0.0, 1.0);
	float local_wind_strength = (1.0 - UV.y) * LocalWindStrength;
	vec2 sweep_effect         = global_wind.xy * GlobalWindStrength * GlobalWindPowerDamp;

	vec3 direction = world - (PlayerPosition + vec3(0.0, PlayerRadius * .5, 0.0));
	direction.xz *= 0.1;
	direction = normalize(direction);
	float dist = distance(PlayerPosition, world);
	float power = smoothstep(PlayerRadius, 0.0, dist);
	direction = (vec4(direction, 1.0) * MODEL_MATRIX).xyz; // world space direction to model space
	vec3 displaceBase = direction * power * PlayerDisplacementAmount * (1.0 - UV.y) / VERTEX.y;
	vec2 fadePos = PlayerPosition.xz + fadeOffset;
	float _dis = distance(PlayerPosition.xz, fadePos);
	
    squishAtDistance = smoothstep(0.0, dist, _dis);

	VERTEX.xz += (vec2(sin(world.x + wind_time_offset) + sweep_effect.x + wind_direction.x, cos(world.y + wind_time_offset) * local_wind_strength + sweep_effect.y + wind_direction.y) * local_wind_strength + length(sweep_effect)) * GlobalHorizontalDisplacementDamp * local_wind_strength + displaceBase.xz * PlayerDisplacementMulitplierXZ;
	VERTEX.y += wind_power * length(sweep_effect) * GlobalVerticalDisplacementDamp * local_wind_strength - length(displaceBase) * PlayerDisplacementMulitplierY;
	VERTEX = clamp(VERTEX * squishAtDistance, VERTEX * 0.01, VERTEX);
}
void fragment() {
	ALBEDO = clamp(mix(BaseColor.rgb, TopColor.rgb + WindColor.rgb * wind_power * WindColorStrength, vec3(1.0 - clamp(UV.y + ColorRampOffset, 0.0, 1.0))), BaseColor.rgb, TopColor.rgb + WindColor.rgb);
	NORMAL = vec3(0.0,1.0,0.0);
}