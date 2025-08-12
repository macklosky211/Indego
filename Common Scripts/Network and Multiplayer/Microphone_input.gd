extends AudioStreamPlayer

enum {LOCAL, RADIO}

@onready var bus_index : int = AudioServer.get_bus_index("Microphone")
@onready var raw_mic : AudioEffectCapture = AudioServer.get_bus_effect(bus_index, 0)
@onready var filter_mic : AudioEffectCapture = AudioServer.get_bus_effect(bus_index, 2)
@onready var mic_output: AudioStreamPlayer3D = $"../Proximity_Output"
@onready var radio_output: AudioStreamPlayer = $"../Radio_Output"

var proximity_playback: AudioStreamGeneratorPlayback
var radio_playback : AudioStreamGeneratorPlayback
var recieved_proximity_buffer : PackedVector2Array = PackedVector2Array()
var recieved_radio_buffer : PackedVector2Array = PackedVector2Array()

func _ready() -> void:
	mic_output.play()
	radio_output.play()
	
	proximity_playback = mic_output.get_stream_playback()
	radio_playback = radio_output.get_stream_playback()

func _process(_delta : float) -> void:
	if is_multiplayer_authority():
		if Input.is_action_pressed("Radio Chat"): process_mic(filter_mic, RADIO)
		elif Input.is_action_just_released("Radio Chat"): filter_mic.clear_buffer()
		if Input.is_action_pressed("Proximity Chat"): process_mic(raw_mic, LOCAL)
		elif Input.is_action_just_released("Proximity Chat"): raw_mic.clear_buffer()
	process_voip()


func process_voip() -> void:
	if recieved_proximity_buffer.size() > 0:
		proximity_playback.push_buffer(recieved_proximity_buffer) # Queue up the recieved audio to play.
		recieved_proximity_buffer.clear() # Clear recieved audio.
	if recieved_radio_buffer.size() > 0:
		radio_playback.push_buffer(recieved_radio_buffer) # Queue up the recieved audio to play.
		recieved_radio_buffer.clear() # Clear recieved audio.

func process_mic(source : AudioEffectCapture, destination : int) -> void:
	var buffer : PackedVector2Array = source.get_buffer(source.get_frames_available()) # This buffer holds the stuff were sending.
	
	#destination.push_buffer(buffer) # Play audio locally.
	
	if buffer.size() > 0: 
		if buffer.size() > 1024: 
			print("Sending LOTS of information... ", buffer.size())
			buffer.resize(512)
		sendData.rpc(buffer, destination) # Send our voice over network.
	source.clear_buffer()

@rpc("any_peer", "call_remote", "unreliable_ordered")
func sendData(data : PackedVector2Array, destination : int) -> void:
	if destination == LOCAL: recieved_proximity_buffer.append_array(data)
	elif destination == RADIO: recieved_radio_buffer.append_array(data)
