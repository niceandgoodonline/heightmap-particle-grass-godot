extends Node3D

@export var coreShaderMaterial: Array[ShaderMaterial]
@export var distantShaderMaterials: Array[ShaderMaterial]
@export var displacementOffset: Vector3 = Vector3.UP

var lastPosition: Vector3

func _ready():
	lastPosition = global_position

func _process(delta: float) -> void:
	if global_position != lastPosition:
		updateGrassMaterials()

func updateGrassMaterials():
	lastPosition = global_position
	coreShaderMaterial[0].set_shader_parameter("PlayerPosition", global_position + displacementOffset)
	for _material in distantShaderMaterials:
		_material.set_shader_parameter("PlayerPosition", global_position + displacementOffset)

func set_core_material(newMaterials):
	coreShaderMaterial = newMaterials

func set_distant_materials(newMaterials):
	distantShaderMaterials = newMaterials