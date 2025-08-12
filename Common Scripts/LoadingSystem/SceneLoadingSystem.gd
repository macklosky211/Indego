class_name SceneLoadingSystem extends Node

signal is_finished_loading()
signal started_loading()

var loading_screen: LoadingScreen = null

func _ready():
	loading_screen = preload("res://Common/Global System/LoadingSystem/LoadingScreen.tscn").instantiate()
	loading_screen.visible = false
	get_tree().root.call_deferred("add_child", loading_screen)
	loading_screen.set_z_as_relative(false)
	loading_screen.z_index = 999

func load_scene_async(scene_path: String):
	started_loading.emit()
	
	ResourceLoader.load_threaded_request(scene_path, "",  true)
	
	await check_scene_loaded(scene_path)
	
	
	var packed_scene: PackedScene = ResourceLoader.load_threaded_get(scene_path)
	var new_scene = packed_scene.instantiate()
	
	if loading_screen.animation_player.is_playing(): await loading_screen.animation_player.animation_finished
	
	get_tree().root.add_child(new_scene)
	
	var current = get_tree().current_scene
	if current: current.queue_free()
	get_tree().current_scene = new_scene
	
	is_finished_loading.emit()


func check_scene_loaded(scene_path: String) -> void:
	while true:
		var status = ResourceLoader.load_threaded_get_status(scene_path)
		if status == ResourceLoader.THREAD_LOAD_LOADED: return
		await get_tree().process_frame # yield until next frame
