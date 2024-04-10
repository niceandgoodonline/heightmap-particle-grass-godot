shader_type spatial;
render_mode blend_mix, cull_back, diffuse_toon, specular_toon;

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
uniform vec3 PlayerPosition   = vec3(0.0);
uniform float PlayerInfluence = 2;
uniform float PlayerRadius    = 3;

varying float wind_power;



void vertex() {
	vec3 world                = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float wind_time_offset    = TIME * LocalWindRate;
	vec2 wind_direction       = normalize(WindDirection);
	vec4 wind_variation       = texture(WindVariationNoise, GlobalWindVariationUVTiling * UV + TIME * 0.01 * GlobalWindVariationDirection);
	vec4 global_wind          = texture(GlobalWindNoise, GlobalWindUVTiling * 0.1 * world.xz + TIME * GlobalWindSpeed * wind_direction * GlobalWindSpeedMagnitude + TIME * 0.01 * wind_direction);
	wind_power                = clamp(global_wind.x * wind_variation.x * GlobalWindVariationStrength, 0.0, 1.0);
	float local_wind_strength = (1.0 - UV.y) * LocalWindStrength;
	vec2 sweep_effect         = global_wind.xy * GlobalWindStrength * GlobalWindPowerDamp;

	VERTEX.xz += (vec2(sin(world.x + wind_time_offset) + sweep_effect.x + wind_direction.x, cos(world.y + wind_time_offset) * local_wind_strength + sweep_effect.y + wind_direction.y) * local_wind_strength + length(sweep_effect)) * GlobalHorizontalDisplacementDamp * local_wind_strength;
	VERTEX.y += wind_power * length(sweep_effect) * GlobalVerticalDisplacementDamp * local_wind_strength;
}
void fragment() {
	ALBEDO = mix(BaseColor.rgb, TopColor.rgb + WindColor.rgb * wind_power * WindColorStrength, vec3(1.0 - clamp(UV.y + ColorRampOffset, 0.0, 1.0)));
	NORMAL = vec3(0.0,1.0,0.0);
}


