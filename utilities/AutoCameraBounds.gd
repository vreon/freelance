extends Node

class_name AutoCameraBounds

export var margin = 1
export(NodePath) var tile_map = null
export(NodePath) var camera_man = null
export var camera_path = "Camera2D"
export(bool) var enabled = true

func _ready():
	if enabled:
		set_camera_limits()

func set_camera_limits():
	var map_node = get_node(tile_map if tile_map else "../TileMap")
	var camera = get_node(camera_man if camera_man else "../Lance").get_node(camera_path)
	var map_limits = map_node.get_used_rect()
	var map_cellsize = map_node.cell_size
	camera.limit_left = (map_limits.position.x + margin) * map_cellsize.x
	camera.limit_right = (map_limits.end.x - margin) * map_cellsize.x
	camera.limit_top = (map_limits.position.y + margin) * map_cellsize.y
	camera.limit_bottom = (map_limits.end.y - margin) * map_cellsize.y
