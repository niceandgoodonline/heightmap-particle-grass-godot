extends Resource
class_name GraphicsSettingsDataResource

@export var particleQuality        : int
@export var coreGrassQuality       : int
@export var distantGrassQuality    : int
@export var outlinePostEffectOn    : bool
@export var pointillismPostEffectOn: bool
@export var paperPostEffectOn      : bool

func _init(
	_particleQuality         = 0, 
	_coreGrassQuality        = 0, 
	_distantGrassQuality     = 0, 
	_outlinePostEffectOn     = 0, 
	_pointillismPostEffectOn = 0, 
	_paperPostEffectOn       = 0
	):
	particleQuality         = _particleQuality
	coreGrassQuality        = _coreGrassQuality
	distantGrassQuality     = _distantGrassQuality
	outlinePostEffectOn     = _outlinePostEffectOn
	pointillismPostEffectOn = _pointillismPostEffectOn
	paperPostEffectOn       = _paperPostEffectOn
