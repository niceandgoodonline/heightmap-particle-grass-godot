extends Resource
class_name GameSessionDataResource

@export var saveID: int
@export var audioData: Resource
@export var graphicData: Resource

func _init(_saveID  = 0, _audioData = null, _graphicData = null):
	saveID = _saveID
