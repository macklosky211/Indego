extends AudioStreamPlayer

var index : int # Index of the microphone audio bus.
var effect : AudioEffectCapture # The capture effect.
var playback : AudioStreamGeneratorPlayback

var input_threashold : float = 0.005

@onready var microphone_output: AudioStreamPlayer = $"../Microphone_Output"

func _ready() -> void:
	call_deferred("setup_audio", multiplayer.get_unique_id())

func setup_audio(id : int) -> void:
	set_multiplayer_authority(id)
	if not is_multiplayer_authority(): set_process(false); return
	
	self.stream = AudioStreamMicrophone.new()
	self.play()
	index = AudioServer.get_bus_index("Microphone")
	effect = AudioServer.get_bus_effect(index, 0) # The first effect should be capture.
	
	playback = microphone_output.get_stream_playback()

func _process(_delta: float) -> void:
	process_mic()

func process_mic() -> void:
	print("Processing mic")
	var sterioData : PackedVector2Array = effect.get_buffer(effect.get_frames_available())
	if sterioData.size() > 0:
		var data := PackedFloat32Array()
		data.resize(sterioData.size())
		var maxAmplitude : float = 0.0
		for i in range(sterioData.size()):
			var value = (sterioData[i].x + sterioData[i].y) / 2
			maxAmplitude = max(value, maxAmplitude)
			data[i] = value
		if maxAmplitude < input_threashold: return
		print(data)
