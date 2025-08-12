extends CharacterBody3D
## This class is for FSM that ARE CharacterBody3D's
class_name State_Controller

var current_state: State:
	set(value):
		if current_state is Object and current_state.has_method("_exit"): current_state._exit(self)
		current_state = value
		#print( "[%s]\t%s\'s current_state set to: %s" % [multiplayer.get_unique_id(), self.name, current_state._get_state_name()] )
		if current_state is Object and current_state.has_method("_enter"): current_state._enter(self)

var current_area : Map_Area:
	set(value):
		#if value is Object: print("[%s]\t%s entered new zone: %s" % [multiplayer.get_unique_id(), self.name, value.name])
		current_area = value 
