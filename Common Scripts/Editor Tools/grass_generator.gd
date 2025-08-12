@tool
extends Node
class_name Grass_Generator

const BATCH_SIZE : int = 5
const FRAME_BUFFER : int = 2
const GRASS_MESH : ArrayMesh = preload("res://Assets/Models/grass.res")


@export_tool_button("Generate Grass")
var generate_grass_button : Callable = generate_grass

@export_tool_button("Clear chidlren")
var clear_children : Callable = (
	func() -> void: 
		for child : Node in get_children(): remove_child(child)
		tiles_to_render.clear()
		tile_properties.clear()
		chunks.clear()
		chunk_keys.clear()
)

@export var target_node : Node

@export var CHUNK_SIZE : float = 4.0

@export var execute_children : bool = true

@export var number_of_threads : int = OS.get_processor_count()

@export var instances_per_tile : int = 1024

@export var should_multithread : bool = true

const TILE_SIZE : float = 4.0
const TILE_AREA : float = TILE_SIZE * TILE_SIZE
const MAX_VISIBLE_INSTANCES : int = 1024 * 50

@export var noise : FastNoiseLite = FastNoiseLite.new()

func find_all_grass_children(target: Node) -> Array[MeshInstance3D]:
	var results: Array[MeshInstance3D] = []
	
	for child: Node in target.get_children():
		if child is MeshInstance3D and child.name.contains("Grass"):
			results.append(child)
		
		results += find_all_grass_children(child)
	
	return results

var thread_mutex : Mutex = Mutex.new()
var threads : Array[Thread] = []

var tiles_to_render : Array[MeshInstance3D]
var tile_properties : Array[Vector2]
var chunks : Dictionary[Vector2, Array]
var chunk_keys : Array[Vector2]

var frame : int = 0

func generate_grass() -> void:
	if target_node == null: push_warning("Target Node was null...."); return
	if execute_children: for child : Node in get_children(): remove_child(child)
	
	tiles_to_render = find_all_grass_children(target_node)
	
	if tiles_to_render.size() <= 0: push_warning("Did not find any grass tiles in the target...?"); return
	
	for tile : Node3D in tiles_to_render:
		tile_properties.append(Vector2(tile.global_position.x, tile.global_position.z))
	
	print("Found ", tiles_to_render.size(), " Tiles to render")
	
	_multithread_my_head_pls()


func _multithread_my_head_pls() -> void:
	var tiles_per_thread : int = ceil(tiles_to_render.size() / float(number_of_threads))
	threads.resize(number_of_threads)
	for i : int in range(number_of_threads):
		threads[i] = Thread.new()
		threads[i].start(_thread_chunk_area.bind(i * tiles_per_thread, tiles_per_thread))
	
	print("Started all threads... %d" % threads.size())
	
	## Wait for all threads to finish then start the rendering process.
	var finished_threads : int = 0
	while finished_threads < number_of_threads:
		for i : int in range(threads.size()):
			if threads[i] != null and threads[i].is_alive() == false:
				await threads[i].wait_to_finish()
				threads[i] = null
				finished_threads += 1
	
	print("Finished calculating all chunks {%d total chunks}... Threads: %d/%d" % [chunks.size(), finished_threads, number_of_threads])
	print(chunks.keys())
	tile_properties.clear()
	
	chunk_keys.assign(chunks.keys())
	
	for chunk_key : Vector2 in chunk_keys:
		var tile_info : Array
		for tile : MeshInstance3D in chunks.get(chunk_key):
			var bb : Vector3 = tile.get_aabb().size
			var new_info : Array = Array([Vector2(bb.x, bb.z), tile.global_transform])
			tile_info.append(new_info)
		chunks.set(chunk_key, tile_info)
	
	var chunks_per_thread : int = ceil(chunk_keys.size() / float(number_of_threads))
	
	print("Chunks per thread: %d/%d " % [chunks_per_thread, chunks.size()])
	print("Starting rendering process...")
	
	for i : int in range(number_of_threads):
		threads[i] = Thread.new()
		threads[i].start(_thread_render_chunk.bind(i * chunks_per_thread, chunks_per_thread))
	
	finished_threads = 0
	while finished_threads < number_of_threads:
		for i : int in range(threads.size()):
			if threads[i] != null and not threads[i].is_alive():
				var new_chunks : Array[Node] = await threads[i].wait_to_finish()
				finished_threads += 1
				threads[i] = null
				print("Chunks generated: %d" % new_chunks.size())
				for child : Node in new_chunks:
					add_child(child, true)
					child.owner = get_tree().edited_scene_root
					for grandchild : Node in child.get_children():
						grandchild.owner = get_tree().edited_scene_root
	print("Finished rendering all threads... good job...")
	tiles_to_render.clear(); chunks.clear(); chunk_keys.clear(); tile_properties.clear();


func _thread_chunk_area(index : int, i_range : int) -> void:
	var thread_chunks : Dictionary[Vector2, Array]
	for i : int in range(i_range):
		if index + i >= tiles_to_render.size(): break
		var tile : MeshInstance3D = tiles_to_render[index + i]
		var global_pos : Vector2 = tile_properties[index + i]
		global_pos = (global_pos / CHUNK_SIZE).floor()
		if thread_chunks.has(global_pos):
			var chunk_info : Array = thread_chunks.get(global_pos)
			chunk_info.append(tile)
		else:
			var new_array : Array
			new_array.append(tile)
			thread_chunks.set(global_pos, new_array)
	print("Finished generating chunk...")
	
	thread_mutex.lock()
	for key : Vector2 in thread_chunks.keys():
		if chunks.has(key): chunks.get(key).append_array(thread_chunks.get(key))
		else: chunks.set(key, thread_chunks.get(key))
	thread_mutex.unlock()

func _thread_render_chunk(index : int, chunks_to_render : int) -> Array[Node]:
	var rendered_nodes : Array[Node]
	for i : int in range(chunks_to_render):
		if (index + i) >= chunk_keys.size(): break
		var key : Vector2 = chunk_keys[i + index]
		
		var total_instances : int = 0
		for tile_info : Array in chunks.get(key):
			var area : float = tile_info[0].x * tile_info[0].y
			total_instances += ceil((area / TILE_AREA) * instances_per_tile)
		
		var multimesh_instance : MultiMeshInstance3D = MultiMeshInstance3D.new()
		multimesh_instance.multimesh = MultiMesh.new()
		multimesh_instance.multimesh.mesh = GRASS_MESH
		multimesh_instance.multimesh.transform_format = MultiMesh.TRANSFORM_3D
		multimesh_instance.multimesh.instance_count = total_instances
		multimesh_instance.multimesh.visible_instance_count = -1
		multimesh_instance.visibility_range_end = 100.0
		multimesh_instance.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
		multimesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		
		var prev_instances : int = 0
		for tile_info : Array in chunks.get(key):
			var bb : Vector2 = tile_info[0]
			var area : float = tile_info[0].x * tile_info[0].y
			var original_transform : Transform3D = tile_info[1]
			var instances : int = ceil((area / TILE_AREA) * instances_per_tile)
			for j : int in range(instances):
				var noise_x : float = noise.get_noise_2d(original_transform.origin.x + j * 13.1, original_transform.origin.z + j * 7.9)
				var noise_z : float = noise.get_noise_2d(original_transform.origin.x + j * 5.2, original_transform.origin.z + j * 11.7)
				var rotation_y : float = noise.get_noise_2d(original_transform.origin.x + j * 3.7, original_transform.origin.z + j * 9.1) * PI * 2
				var adjusted_scale : float = 0.8 + 0.4 * noise.get_noise_2d(original_transform.origin.x + j * 1.3, original_transform.origin.z + j * 1.7)
				var offset : Vector3 = Vector3(noise_x * bb.x / 2.0, 0.0, noise_z * bb.y / 2.0)
				var trans : Transform3D = original_transform
				trans.origin += trans.basis * offset
				trans.basis = trans.basis.rotated(Vector3.UP, rotation_y)
				trans.basis.scaled(Vector3.ONE * adjusted_scale)
				
				multimesh_instance.multimesh.set_instance_transform(j + prev_instances, trans)
			
			prev_instances += instances
		
		
		var occlusion_instance : OccluderInstance3D = OccluderInstance3D.new()
		occlusion_instance.occluder = BoxOccluder3D.new()
		occlusion_instance.occluder.size = Vector3(CHUNK_SIZE, 1, CHUNK_SIZE)
		occlusion_instance.position = Vector3(key.x * CHUNK_SIZE + (CHUNK_SIZE / 2), 0, key.y * CHUNK_SIZE + (CHUNK_SIZE / 2))
 		
		multimesh_instance.add_child(occlusion_instance, true)
		
		rendered_nodes.append(multimesh_instance) 
	
	return rendered_nodes
