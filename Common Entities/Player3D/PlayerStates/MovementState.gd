class_name Movement_State extends PlayerState

var tween : Tween

func physics_update(player : Player, _delta : float) -> void:
	if tween != null and tween.is_running(): return
	var input : Vector2 = Input.get_vector("Left", "Right", "Backward", "Forward")
	
	var basis : Basis = player.basis
	var direction : Vector3 = (basis * Vector3(input.x, 0, -input.y)).normalized()
	var velocity : Vector3 = direction * 5.0 
	
	if Input.is_action_pressed("Jump"): 
		if player.vault_system.can_vault():
			var edge_position : Vector3 = player.vault_system.vault_destination()
			tween = get_tree().create_tween()
			var durration : float = 1.0 / max(player.velocity.length(), 0.01)
			durration = clampf(durration, 0.1, 1.0)
			var final_destination : Vector3 = edge_position + Vector3(0.0, 1.0, 0.0)
			tween.tween_property(player, "global_position", final_destination, durration)
			tween.play()
			await tween.finished
			tween.kill()
			return
		elif player.is_on_floor():
			player.velocity.y += 5.0
	
	player.velocity.x = velocity.x
	player.velocity.z = velocity.z
