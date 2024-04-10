extends Node

@export var gameSessionSettings: GameSessionDataResource

func _ready():
	__subscribe_to_events(true)
	GameSessionEvents.sync_audio_settings.emit(gameSessionSettings.audioData)
	GameSessionEvents.sync_graphic_settings.emit(gameSessionSettings.graphicData)

func handle_game_session_request(requester):
	requester.set_game_session(gameSessionSettings)

func handle_load_settings(saveID: int):
	print("TODO load")

func handle_save_settings(saveID: int):
	print("TODO save")

func handle_set_particle_quality(value: int):
	gameSessionSettings.graphicData.particleQuality = value
	GameSessionEvents.sync_graphic_settings.emit(gameSessionSettings.graphicData)

func handle_set_close_grass_quality(value: int):
	gameSessionSettings.graphicData.coreGrassQuality = value
	GameSessionEvents.sync_graphic_settings.emit(gameSessionSettings.graphicData)

func handle_set_far_grass_quality(value: int):
	gameSessionSettings.graphicData.distantGrassQuality = value
	GameSessionEvents.sync_graphic_settings.emit(gameSessionSettings.graphicData)

func handle_toggle_outline_post_effect(state: bool):
	gameSessionSettings.graphicData.outlinePostEffectOn = state
	GameSessionEvents.sync_graphic_settings.emit(gameSessionSettings.graphicData)

func handle_toggle_pointillism_post_effect(state: bool):
	gameSessionSettings.graphicData.pointillismPostEffectOn = state
	GameSessionEvents.sync_graphic_settings.emit(gameSessionSettings.graphicData)

func __subscribe_to_events(state: bool):
	if state:
		GameSessionEvents.load_settings.connect(handle_load_settings)
		GameSessionEvents.save_settings.connect(handle_save_settings)
		GameSessionEvents.request_game_session.connect(handle_game_session_request)

		GameSessionEvents.set_particle_quality.connect(handle_set_particle_quality)
		GameSessionEvents.set_close_grass_quality.connect(handle_set_close_grass_quality)
		GameSessionEvents.set_distant_grass_quality.connect(handle_set_far_grass_quality)
		GameSessionEvents.toggle_outline_post_effect.connect(handle_toggle_outline_post_effect)
		GameSessionEvents.toggle_pointillism_post_effect.connect(handle_toggle_pointillism_post_effect)

	else:
		GameSessionEvents.load_settings.disconnect(handle_load_settings)
		GameSessionEvents.save_settings.disconnect(handle_save_settings)
		GameSessionEvents.request_game_session.disconnect(handle_game_session_request)

		GameSessionEvents.set_particle_quality.disconnect(handle_set_particle_quality)
		GameSessionEvents.set_close_grass_quality.disconnect(handle_set_close_grass_quality)
		GameSessionEvents.set_distant_grass_quality.disconnect(handle_set_far_grass_quality)
		GameSessionEvents.toggle_outline_post_effect.disconnect(handle_toggle_outline_post_effect)
		GameSessionEvents.toggle_pointillism_post_effect.disconnect(handle_toggle_pointillism_post_effect)

