extends CharacterBody3D
class_name Creature_Controller

## Global definition of a "monster"


@onready var Delay_State_Timer : Timer = $Delay_State_Timer
@onready var Stun_Timer : Timer = $Stun_Timer
@onready var Stun_Immunity_Timer : Timer = $Stun_Immunity_Timer
@onready var Nav_Agent : NavigationAgent3D = $NavigationAgent3D

## The current 'state' that the creature is in.
## This state dictates behaviors and interactions that the monster can do.
var creature_state : Creature_State:
	set(value):
		#if Delay_State_Timer.wait_time != 0.0: return
		if creature_state is Object and creature_state.has_method("_exit"): creature_state._exit(self)
		creature_state = value
		print(creature_state._get_state_name())
		if creature_state is Object and creature_state.has_method("_enter"): creature_state._enter(self)


## This is used to get a quick lookup as to where this creature is.
var current_area : Map_Area:
	set(value):
		if value is Object: print("[", self.name, "] entered new zone: ", value.name)
		current_area = value

## This variable dictates what the creature should be 'looking' directly at.
var target_to_look_at : Vector3 = Vector3.ZERO

## Flag as to if we should use target_to_look_at or not.
var should_look_at_target : bool = true
var should_lock_rotation : bool = true

## This represents how active the monster is. When this 'peak's start de-escalating activity
var intensity : float = 0.0

## Used in case of heavy performance. Delays the handling of the current state to every 1/x physics frames.
var frame_delay : float = 5.0

## Getter is designed to be only called 1x per frame, so it increases itself when its referenced.
var current_frame : float = 0.0:
	get():
		current_frame += 1 # May cause recurrsion.
		return current_frame

## Self explanitory
var should_move_and_slide : bool = true

## Used to add gravity AFTER _update() has finished.
var should_add_gravity : bool = true

## A prediction made by a monster as to where the player will move to. This allows for more realistic chases.
var predicted_player_location : Vector3 = Vector3.ZERO

## Global Idle state. used when the monster shouldnt be doing anything.
@onready var Idle : Creature_State = $States/Idle

## This state causes the creature to move towards a different zone, this target will be assigned by the director
@onready var Traverse_To_Area : Creature_State = $States/Traverse_To_Area

## Used to call area specific functions. has sub-states.
@onready var Idle_In_Area : Creature_State = $States/Idle_In_Area

## This state causes the creature to be on alert for a period of time.
## Triggers: Player was noticed by creature or player interacted with something that alerted this monster.
## Small increase to 'intensity'
@onready var Alert : Creature_State = $States/Alert

## This state causes a creature to search its immediate area for anything out of place (Player).
## Triggers: Creature was alerted but didnt find anything before alert timer ended.
#@onready var Investigating : Creature_State = $States/Investigating

## This state causes the creature to chase the closest player.
## Triggers: Player was seen while Alert or Investigating, or director specified event.
## This state specially uses 'predicted player location' which is a variable that does its best to approximate where the player will be going next.
@onready var Chasing : Creature_State = $States/Chasing

## This is a state that allows for the player to counter the creature
## Triggers: Enviornment stunned the creature (Falling Debris, Electrified water, etc) or the player blinded the creature.
## This state is entirely time based, time is set externally by whatever causes the stun.
## Creature has I-frames before being able to be stunned again.
#@onready var Stunned : Creature_State = $States/Stunned

func _ready() -> void:
	if not multiplayer.is_server(): set_process(false); set_physics_process(false); return
	creature_state = Idle_In_Area

func _physics_process(delta: float) -> void:
	if fmod(current_frame, frame_delay) == 0 and creature_state is Object and creature_state.has_method("_update"): creature_state._update(self, delta)
	if should_add_gravity and not is_on_floor(): velocity += get_gravity() * delta
	if should_look_at_target  and target_to_look_at != global_position:
		look_at(target_to_look_at)
		if should_lock_rotation: rotation.x = 0.0; rotation.z = 0.0
	if should_move_and_slide: move_and_slide()

## Returns a boolean specifying if this creature can be stunned. This is based on the Stun_Immunity_Timer.
func _can_be_stunned() -> bool: return Stun_Immunity_Timer.wait_time == 0.0
