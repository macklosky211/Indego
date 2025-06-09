extends MultiplayerSpawner

var Player_Scene : PackedScene = preload("res://Scenes/player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		spawn_function = player_spawn_function

func player_spawn_function(vars) -> Node:
	var id = vars[0]
	var new_player : Node = Player_Scene.instantiate()
	new_player.position = Vector3(0,10,0)
	new_player.set_multiplayer_authority(id, true)
	
	return new_player
