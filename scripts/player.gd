extends CharacterBody2D


const SPEED = 400.0
const JUMP_VELOCITY = -750.0
const SHOOT_COOLDOWN = 0.1  # Time (in seconds) between each shot

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 2.2
# Preload the projectile

@onready var animated_sprite = $AnimatedSprite2D
@onready var projectile_scene = load("res://scenes/projectile.tscn") 
@onready var main = get_tree().get_root().get_node("Game")
@onready var coyote_timer = $CoyoteTimer

var is_mouse_held = false  # Track mouse button hold state
var time_since_last_shot = 0.0  # Track time since last shot

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() || !coyote_timer.is_stopped()):
		velocity.y = JUMP_VELOCITY
		
	# Get input direction: -1, 0, 1
	var direction = Input.get_axis("move_left", "move_right")
	var spawn_offset = Vector2(25, -40)
	if direction > 0:
		spawn_offset = Vector2(40, -40)
		animated_sprite.flip_h = false
	elif direction < 0:
		spawn_offset = Vector2(-40,-40)
		animated_sprite.flip_h = true
	
	var was_on_floor = is_on_floor()
	
	
	# Play animations
	if is_on_floor():
		if direction == 0:
			if is_mouse_held:
				animated_sprite.play("idle_shoot")  # Replace with your animation name
			else:
				animated_sprite.play("idle")
		else:
			if is_mouse_held:
				animated_sprite.play("run_shoot")
			else:
				animated_sprite.play("run")
	else:
		if is_mouse_held:
				animated_sprite.play("jump_shoot")
		else:
			animated_sprite.play("jump")
	
	# Handle movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	
	# Handle shooting with cooldown
	if is_mouse_held:
		time_since_last_shot -= delta  # Decrease the cooldown timer
		if time_since_last_shot <= 0:  # If cooldown has expired
			if animated_sprite.flip_h:
				shoot_projectile(spawn_offset, -1)
			else:
				shoot_projectile(spawn_offset, 1)
				
			time_since_last_shot = SHOOT_COOLDOWN  # Reset the cooldown
	
	move_and_slide()
	
	if was_on_floor && !is_on_floor():
		coyote_timer.start()

func _input(event):
	# Check if the left mouse button is pressed or released
	if Input.is_action_pressed("shoot"):
		is_mouse_held = true
	else:
		is_mouse_held = false
		

func shoot_projectile(spawn_offset, direction):
	# Create a new instance of the projectile scene
	var projectile = projectile_scene.instantiate()

	# Set the starting position of the projectile slightly above the player's position
	projectile.position = global_position + spawn_offset

	# Calculate the direction from the player to the mouse click
	var mouse_position = get_global_mouse_position()

	# Assign the direction to the projectile
	projectile.direction = direction

	# Add the projectile to the scene tree
	get_parent().add_child(projectile)
