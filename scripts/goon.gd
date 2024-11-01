extends CharacterBody2D

# CONSTANTS
const SPEED = 400.0
const JUMP_VELOCITY = -750.0

# Variables
var astar: AStar2D

var path = PackedVector2Array()
var current_index = 0
var target = null
const PLAYER_MOVE_THRESHOLD = 50  # Adjust as needed
const PATH_UPDATE_INTERVAL = 0.5  # Update path every 0.5 seconds

@onready var waypoints_node = get_parent().get_node("WayPoints")
@onready var animated_sprite = $AnimatedSprite2D
@onready var agent: NavigationAgent2D = $NavigationAgent2D  # Reference the agent
@onready var player = get_parent().get_node("Player")

var time_since_last_update = 0.0  # Initialize the timer
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 2.2
var last_player_position: Vector2  # Store the last player position
var direction

func _ready():
	print(waypoints_node)
	
	astar = AStar2D.new()  # A* instance
	setup_astar()
	path = get_path_to_player(position, player.position)
	
func setup_astar():
	for marker in waypoints_node.get_children():
		var id = int(String(marker.name))
		var position = marker.global_position
		astar.add_point(id,position)
	
	  # Connect points sequentially
	for i in range(1, 30):
		astar.connect_points(i, i + 1, true)  # Ground
	for i in range(31, 35):
		astar.connect_points(i, i + 1, true)  # Left platform
	for i in range(36, 40):
		astar.connect_points(i, i + 1, true)  # Right platform
	for i in range(41, 45):
		astar.connect_points(i, i + 1, true)  # mid platform
	# left platform jump
	astar.connect_points(5, 31, true)  # Bidirectional connection
	astar.connect_points(35, 12, true)  # Bidirectional connection
	
	# right platform jump
	astar.connect_points(18, 36, true)  # Bidirectional connection
	astar.connect_points(25, 40, true)  # Bidirectional connection
	
	# Mid platform jump
	astar.connect_points(35, 41, true)  # Bidirectional connection
	astar.connect_points(36, 45, true)  # Bidirectional connection
	
	# Set jump cost
	astar.set_point_weight_scale(31, 2)  # Set cost of node 3 as 2
	astar.set_point_weight_scale(35, 2)  
	astar.set_point_weight_scale(36, 2)  
	astar.set_point_weight_scale(40, 2) 
	astar.set_point_weight_scale(41, 2)  
	astar.set_point_weight_scale(45, 2)  
	

# Find path to the player, return array of nodes leading to player
func get_path_to_player(enemy_position, player_position) -> PackedVector2Array:
	var start_id = astar.get_closest_point(enemy_position)
	var end_id = astar.get_closest_point(player_position)
	
	if astar.has_point(start_id) and astar.has_point(end_id):
		return astar.get_point_path(start_id, end_id)
		
	return PackedVector2Array()


func _physics_process(delta):
	#Apply gravity
	velocity.y += gravity * delta
	
	#Update new path every frame
	path = get_path_to_player(position, player.position)
	
	#Play animation
	play_Animation()
	
	# Handl movement
	move_along_path(delta)

func move_along_path(delta):
	if current_index >= path.size():
		return  # Exit if index is out of bounds
	
	# Get next node
	var current_waypt = path[current_index]
	
	 # Check if the next step requires a jump (cost = 2)
	var cost = astar.get_point_weight_scale(astar.get_closest_point(current_waypt))
	
	# Only update horizontal velocity when on the ground
	if is_on_floor():
		# Calculate direction to the waypoint
		direction = (current_waypt - position).normalized()
		
		# Move towards target
		velocity.x = direction.x * SPEED
		
		# Check if we need to jump
		if cost == 2 and current_waypt.y < position.y:
			jump()  # Trigger jump if cost is 2 and next node is higher than current position
	else:
		# In the air, maintain current velocity
		pass  
	move_and_slide()
	
	# Check if enemy has reached target
	if position.distance_to(current_waypt) < 4:
		current_index += 1 # Move to next node on path
		# if reached player, stop
		# If end of path reached, stop moving
		if current_index >= path.size():
			path = PackedVector2Array()	# Clear the path to stop movement
			current_index = 0;
 
func play_Animation():
	if velocity.x >= 0:
		animated_sprite.flip_h = false
	else:
		animated_sprite.flip_h = true
	
	var was_on_floor = is_on_floor()
	
	
	# Play animations
	if is_on_floor():
		if velocity.x == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

func jump():
	if is_on_floor():  # Ensure enemy can only jump when on the ground
		velocity.y = JUMP_VELOCITY


