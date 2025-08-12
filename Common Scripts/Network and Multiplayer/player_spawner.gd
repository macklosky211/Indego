extends MultiplayerSpawner

var Player_Scene : PackedScene = preload("res://Entities/Player/player.tscn")

var Spawn_Positions : Array[Vector3]

var playerCount : int = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child : Node3D in get_children():
		Spawn_Positions.append(child.global_position)
	spawn_function = player_spawn_function

func player_spawn_function(vars : Array) -> Node:
	#print("Player is being spawned in.")
	var steamID : int = vars[0]
	var playerID : int = vars[1]
	var new_player : Node = Player_Scene.instantiate()
	print(new_player.get_class())
	new_player.name = str(playerID)
	new_player.steamID = steamID 
	new_player.position = Spawn_Positions[playerCount%4]
	playerCount += 1
	
	new_player.set_multiplayer_authority(playerID, true)
	
	if playerID != multiplayer.get_unique_id(): return new_player
	for child : Node in new_player.get_children():
		if child is Camera3D: child.make_current()
	
	return new_player
