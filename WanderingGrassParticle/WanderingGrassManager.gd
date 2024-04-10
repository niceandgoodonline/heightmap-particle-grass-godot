extends Node3D
class_name WanderingGrassManager

@export_group("External Dependencies")
@export var heightMap: Texture2D
@export var normalMap: Texture2D

@export_group("Sync")
@export var syncTarget: Node3D
@export var syncOrigin: Vector3 = Vector3.ZERO
@export var syncRate: float = 0.3
@export var syncLoopOn: bool = true
@export var syncAllowed: bool = true

@export_group("Close Grass")
@export var closeGrassOn: bool = true
@export var currentCloseGrassQuality = 1
@export var closeGrassQualityScenes: Array[PackedScene]
@export var closeGrassInstance: Node3D

@export_group("Distant Grass")
@export var distantGrassOn: bool = true
@export var distantGrassInstanceNumber: int = 8
@export var currentDistantGrassQuality = 1
@export var distantGrassQualityScenes: Array[PackedScene]
@export var distantGrassInstance: Node3D

var syncTimer: Timer

func _ready():
	syncTimer = Timer.new()
	add_child(syncTimer)
	setup_core_grass()
	setup_distant_grass()
	__subscribe_to_events(true)
	sync_to_target()

func sync_to_target():
	while syncLoopOn:
		if syncAllowed:
			global_position = syncTarget.global_position.snapped(Vector3.ONE)
		syncTimer.start(syncRate)
		await syncTimer.timeout

func __subscribe_to_events(state: bool):
	pass
	if state:
		GameSessionEvents.sync_graphic_settings.connect(handle_sync_graphic_settings)
	else:
		GameSessionEvents.sync_graphic_settings.disconnect(handle_sync_graphic_settings)

func handle_sync_graphic_settings(settingsData):
	if settingsData.coreGrassQuality != currentCloseGrassQuality:
		currentCloseGrassQuality = settingsData.coreGrassQuality
		setup_core_grass()

	if settingsData.distantGrassQuality != currentDistantGrassQuality:
		currentDistantGrassQuality = settingsData.distantGrassQuality
		setup_distant_grass()

func setup_core_grass():
	if closeGrassInstance != null:
		closeGrassInstance.queue_free()
		closeGrassInstance = null

	if currentCloseGrassQuality > -1:
		closeGrassInstance = closeGrassQualityScenes[currentCloseGrassQuality].instantiate()
		add_child(closeGrassInstance)
		syncTarget.set_core_material(closeGrassInstance.grassMaterial)
		_init_close_instance()

func setup_distant_grass():
	if distantGrassInstance != null:
		distantGrassInstance.queue_free()
		distantGrassInstance = null

	if currentDistantGrassQuality > -1:
		distantGrassInstance = distantGrassQualityScenes[currentDistantGrassQuality].instantiate()
		add_child(distantGrassInstance)
		syncTarget.set_distant_materials(distantGrassInstance.grassMaterial)
		_init_distant_instance()

func _init_close_instance():
	if closeGrassInstance != null:
		_set_close_maps()
		closeGrassInstance.instanceNumber = 1
		closeGrassInstance._update_instance_number()

func _set_close_maps():
	closeGrassInstance.set_maps(heightMap, normalMap)		

func _init_distant_instance():
	if distantGrassInstance != null:
		_set_distant_maps()
		distantGrassInstance.instanceNumber = distantGrassInstanceNumber
		distantGrassInstance._update_instance_number()

func _set_distant_maps():
	distantGrassInstance.set_maps(heightMap, normalMap)
