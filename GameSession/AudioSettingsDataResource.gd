extends Resource
class_name AudioSettingsDataResource

@export var gameVolume   : float
@export var musicVolume  : float
@export var npcVolume    : float
@export var ambientVolume: float

func _init(
	_gameVolume = 1.0,
	_musicVolume = 1.0,
	_npcVolume = 1.0,
	_ambientVolume = 1.0
	):
	gameVolume    = _gameVolume
	musicVolume   = _musicVolume
	npcVolume     = _npcVolume
	ambientVolume = _ambientVolume