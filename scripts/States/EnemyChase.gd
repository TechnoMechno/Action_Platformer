extends State
class_name EnemyChase
#
#@export var enemy: CharacterBody2D
#@export var move_speed := 300.0
#var player : CharacterBody2D
#
#
#func Enter():
	#player = get_tree().get_first_node_in_group("Player")
#
#func Physics_Update(delta: float):
	#var direction = (player.global_position - enemy.global_position).normalized()
	#
	#enemy.velocity.x = direction.x * move_speed
