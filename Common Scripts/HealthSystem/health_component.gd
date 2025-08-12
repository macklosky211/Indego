class_name HealthComponent extends Node

signal health_decreased(current_health : float)
signal health_increased(current_health : float)
signal died()

@export_category("Standard Settings")
@export var maximum_health : float = 100.0
@export var minimum_health : float = 0.0

@export_category("Immunity Frames")
@export var immunity_enabled : bool = true
@export var immunity_time : float = 0.0
var last_hit_time : int = 0

var current_health : float = maximum_health

## Emits Health_Increased after health is updated.
func give_health(amount : float = 0.0) -> void:
	assert(amount > 0, "Attempted to give negative HP.") 
	current_health = clampf(current_health + amount, minimum_health, maximum_health)
	health_increased.emit(current_health)

## Emits Health_Decreased after health is updated.
func take_health(amount : float = 0.0) -> void:
	assert(amount > 0, "Attempted to remove negative HP (-- becomes positive)")
	if immunity_enabled:
		var current_time : int = Time.get_ticks_msec()
		var time_elapsed : float = float(current_time - last_hit_time) * 0.001 # 0.001 (milli) -> 1.0 (second) *= 0.001
		if time_elapsed < immunity_time: return
	
	current_health = clampf(current_health - amount, minimum_health, maximum_health)
	health_decreased.emit(current_health)
	if (current_health <= minimum_health): died.emit()
	last_hit_time = Time.get_ticks_msec()

func is_dead() -> bool: return current_health <= minimum_health

func _to_string() -> String:
	return "(Health [%.3f])" % current_health
