extends Node2D

const FACE = preload("res://scenes/face.tscn")
var tileMap
var graph
var cell_size = 48

# Called when the node enters the scene tree for the first time.
func _ready():
	graph = AStar2D.new()
	tileMap = get_parent().get_node("tilemap")
	createMap()
	
func createMap():
	var cells = tileMap.get_used_cells(0)
	var platforms = get_platform_objects()
	
	for cell in cells:
		var above = Vector2(cell.x,cell.y - 1)
		if !(above in cells):
			var face = FACE.instantiate() 
			face.position = tileMap.map_to_local(above) + Vector2(cell_size/2, cell_size/2)
			add_child(face)
			call_deferred("add_child", face)
	
	for platform in platforms:
		var above = Vector2(platform.position.x,platform.position.y - 1)
		if !(above in platforms):
			var face = FACE.instantiate() 
			face.position = tileMap.map_to_local(above) + Vector2(24/2, 24/2)
			add_child(face)

func get_platform_objects():
	return get_tree().get_nodes_in_group("platforms")  # Group your platforms

