extends Node
class_name Director


## Map_Area is a class that holds information about each zone, and most importantly, the zones position.
@export var Map_Areas : Array[Map_Area]

## Represents the average intensity of all the players.
var collective_intensity : float = 0.0

## This timer is what causes the main logical loop for this director.
@onready var Director_Timer : Timer = $Director_Timer

var Players : Array[Player_Controller]
var Creatures : Array[Creature_Controller]

## The director itself is a FSM, the states are defined in /Director_States
var director_state : Director_State:
	set(value):
		if director_state is Object and director_state.has_method("_exit"): director_state._exit(self)
		director_state = value
		if director_state is Object and director_state.has_method("_enter"): director_state._enter(self)

##--- Director States ---##
@onready var Low_Intensity : Director_State


func _ready() -> void:
	if not multiplayer.is_server(): set_process(false); set_physics_process(false); return
	Director_Timer.timeout.connect(_main)
	
	var area : Map_Area
	
	for player in get_node("/root/Main/Players").get_children():
		Players.append(player)
	
	for creature in get_node("/root/Main/Creatures").get_children():
		Creatures.append(creature)

func _main() -> void:
	if director_state is Object and director_state.has_method("_update"): director_state._update(self)

func _list_all_information() -> void:
	print("---  Players  ---")
	for player in Players:
		print(player.name, " ", player.current_area.name)
	
	print("--- Creatures ---")
	for creature in Creatures:
		print(creature.name, " ", creature.current_area.name)
	print("-----------------")
