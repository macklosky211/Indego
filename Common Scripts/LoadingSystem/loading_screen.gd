class_name LoadingScreen extends ColorRect

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	SceneLoader.is_finished_loading.connect(finish_animation)
	SceneLoader.started_loading.connect(start_animation)

func start_animation() -> void:
	visible = true
	if animation_player.is_playing(): await animation_player.animation_finished
	print("Starting animation")
	material.set("shader_parameter/fade_direction", randi_range(0, 3))
	animation_player.play("Loading Animation", -1, -1.0, true)

func finish_animation() -> void:
	if animation_player.is_playing(): await animation_player.animation_finished
	print("Finishing Animation")
	material.set("shader_parameter/fade_direction", randi_range(0, 3))
	animation_player.play("Loading Animation")
	await animation_player.animation_finished
	visible = false
