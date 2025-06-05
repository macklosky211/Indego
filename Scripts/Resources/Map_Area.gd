extends Node ## May want to be a Resource... not sure yet.
class_name Map_Area

## This box defines each Map_Area's physical location.
@export var Map_Collider : Area3D

## Each zone will have its own navigation mesh.
@export var Navigation_Mesh : NavigationRegion3D


func get_all_creatures() -> Array[Creature_Controller]:
	var found_monsters : Array[Creature_Controller]
    if Map_collider == null: push_error("Map_Collider for ", name, " was null.")
    for children in Map_Collider.get_overlapping_bodies():
        if child is Creature_Controller: found_monsters.append(child)
    return found_monsters

func get_all_players() -> Array[Player_Controller]:
    var found_players : Array[Player_Controller]
    if Map_collider == null: push_error("Map_Collider for ", name, " was null.")
    for children in Map_Collider.get_overlapping_bodies():
        if child is Player_Controller: found_players.append(child)
    return found_players
