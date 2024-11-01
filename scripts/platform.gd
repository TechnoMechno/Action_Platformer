extends AnimatableBody2D

@onready var collision = $CollisionPolygon2D
@onready var area = $Area2D

const PLAYER_LAYER = 1 << 2

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_down"):
		await get_tree().process_frame
		set_collision_layer_value(2, false)
	elif event.is_action_released("move_down"):
		set_collision_layer_value(2, true)
