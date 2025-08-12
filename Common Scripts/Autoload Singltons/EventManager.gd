class_name EventDriver extends Node

var player_events : player_events_class = player_events_class.new()

class player_events_class:
	signal player_died(player_id : int, cause_of_death : String)
	signal player_was_hurt(player_id : int, amount : float)
	signal player_was_healed(player_id : int, amount : float)

## Any event you want to trigger globally across all clients (Including local client)
## Only supports up to 5 arguments... be careful, and they need to be passed as an array.
@rpc("any_peer", "call_local")
func broadcast_event(event : Signal, vars : Array) -> void:
	if vars.size() != event.emit.get_argument_count(): push_error("Missmatching argument size for ", event.get_name())
	match vars.size():
		0: event.emit()
		1: event.emit(vars[0])
		2: event.emit(vars[0], vars[1])
		3: event.emit(vars[0], vars[1], vars[2])
		4: event.emit(vars[0], vars[1], vars[2], vars[3])
		5: event.emit(vars[0], vars[1], vars[2], vars[3], vars[4])
		_: push_error("Too many arguments to broadcast event")
