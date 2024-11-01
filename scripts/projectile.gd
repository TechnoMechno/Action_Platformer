extends AnimatableBody2D

@export var speed = 900  # Speed of the projectile
var direction: int = 0  # Direction the projectile will travel

func _ready():
	# Set a timer to automatically delete the projectile after 2 seconds
	await get_tree().create_timer(2.0).timeout
	queue_free()

func _physics_process(delta):
	# Move the projectile in the assigned direction
	position.x += direction * speed * delta  # Update position with direction and speed
