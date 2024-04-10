extends Node

signal load_settings(saveID: int)
signal save_settings(saveID: int)
signal request_game_session(requester)

signal set_particle_quality(quality: int)
signal set_close_grass_quality(quality: int)
signal set_distant_grass_quality(quality: int)
signal toggle_outline_post_effect(state: bool)
signal toggle_pointillism_post_effect(state: bool)

signal sync_audio_settings(data)
signal sync_graphic_settings(data)
signal sync_frog_settings(data)
