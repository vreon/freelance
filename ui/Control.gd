extends Control
tool

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	rect_rotation = 5

func _process(delta):
	rect_rotation = sin(OS.get_ticks_msec() * 0.001) * 10