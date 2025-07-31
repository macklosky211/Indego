## External actions needed:
## Player.default_speed needs to be set. (&Speed needs to be exposed)


## Coffee shop speed boost.
func ZOOMIES_20_10() -> void:
    player.speed = 20.0
    await get_tree().create_timer(10).timeout
    player.speed = player.default_speed

## Coffee shop slow down.
func SLOW_2.5_5() -> void:
    player.speed = 2.5
    await get_tree().create_timer(10).timeout
    player.speed = player.default_speed

func gravity_low() -> void:
    ProjectSettings.set_settings("physics/3d/default_gravity", 9.8 * 0.25)

func gravity_light() -> void:
    ProjectSettings.set_settings("physics/3d/default_gravity", 9.8 * .75)

func gravity_high() -> void:
    ProjectSettings.set_settings("physics/3d/default_gravity", 9.8 * 2.0)

func reset_gravity() -> void:
    ProjectSettings.set_settings("physics/3d/default_gravity", 9.8)