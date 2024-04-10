@tool
extends Node3D

@export_group("Dependencies")
@export var grassParticleTemplate: PackedScene
@export var grassMaterialTemplate: ShaderMaterial
@export var grassPPM: ShaderMaterial

@export_group("Instances")
@export var isCoreGrass: bool = true
@export var instanceNumber: int = 0
@export var grassParticle: Array[GPUParticles3D]
@export var grassMaterial: Array[ShaderMaterial]

@export_group("Tool Functions")
@export var update_instance_number: bool = false:
	set(b):
		_update_instance_number()

@export var update_sync_origin:bool = false:
	set(b):
		syncOrigin = get_parent().syncTarget.global_position
		_update_sync_origin()
@export var syncOrigin: Vector3 = Vector3.ZERO:
	set(value):
		syncOrigin = value

@export var update_fade_distance:bool = false:
	set(b):
		_update_fade_distance()
@export var fadeDistance: Vector2 = Vector2(20,20) : 
	set(value):
		fadeDistance = value

@export var update_grass_spacing:bool = false:
	set(b):
		_update_grass_spacing()
@export var grassSpacing: float = 102:
	set(value):
		grassSpacing = value

func set_maps(_height, _normal):
	grassPPM.set_shader_parameter("heightmap", _height)
	grassPPM.set_shader_parameter("heightmap_normals", _normal)

func _update_fade_distance():
	for _material in grassMaterial:
		_material.set_shader_parameter("fadeOffset", fadeDistance)

func _update_grass_spacing():
	for index in range(len(grassParticle)):
		var _c: float = 2.0 * PI
		var _step: float = _c / instanceNumber
		var _angle: float = _step
		
		grassParticle[index].position = _generate_spawn_point(_angle * index)
		var _v2 = Vector2(grassParticle[index].position.x, grassParticle[index].position.z)
		grassMaterial[index].set_shader_parameter("ParticleSystemOffset", _v2)

func _update_sync_origin():
	for _material in grassMaterial:
		_material.set_shader_parameter("PlayerPosition", syncOrigin)

func _update_instance_number():
	if isCoreGrass:
		if instanceNumber == 0 and len(grassParticle) > 0:
			_remove_grass_particle()
		else:
			grassParticle.clear()
			grassMaterial.clear()
			_add_grass_particle()
	else:
		var _currentInstanceNumber = len(grassParticle)
		if _currentInstanceNumber < 1:
			grassParticle.clear()
			grassMaterial.clear()
			for index in range(instanceNumber):
				_add_grass_particle()
		elif instanceNumber != _currentInstanceNumber:
			if instanceNumber < _currentInstanceNumber:
				for _index in range(_currentInstanceNumber, instanceNumber, -1):
					_remove_grass_particle()
			else:
				for _index in range(_currentInstanceNumber, instanceNumber):
					_add_grass_particle()

	_update_grass_spacing()
	_update_sync_origin()
	_update_fade_distance()

func _add_grass_particle():
	var _particle = grassParticleTemplate.instantiate()
	add_child(_particle)
	grassParticle.append(_particle)
	grassParticle[0].set_material_override(grassMaterialTemplate)
	grassMaterial.append(_particle.get_material_override())

func _remove_grass_particle():
	var _particle = grassParticle.pop_back()
	grassMaterial.pop_back()
	_particle.queue_free()

func _generate_spawn_point(angle: float) -> Vector3:
	var _direction = Vector2(sin(angle), cos(angle) * -1)
	var _point = Vector3(
		_direction.x * grassSpacing,
		0.0,
		_direction.y * grassSpacing
		)
	return _point

var origin: float = 102.0
var originIdentity = {
	0: [-1,-1],
	1: [0, -1],
	2: [1,-1],
	3: [1, 0],
	4: [1, 1],
	5: [0, 1],
	6: [-1, 1],
	7: [-1,0]
}