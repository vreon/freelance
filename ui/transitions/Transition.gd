extends CanvasLayer

const DEFAULT_COLOR = Color(0, 0, 0, 1)

export(Color, RGBA) var color = DEFAULT_COLOR setget set_color
export(float, -1, 1) var smooth_percent = 0 setget set_smooth_percent
export(float) var duration = 1 setget set_duration
export var texture = "radial" setget set_texture
var percent = 0

onready var mat = $TextureRect.material
onready var anim = $AnimationPlayer

func _ready():
	set_texture(texture)

func _process(_delta):
	mat.set_shader_param("percent", percent)
	
func set_duration(duration):
	anim.playback_speed = 1 / duration
	
func set_color(value):
	color = value
	mat.set_shader_param("color", value)
	
func set_smooth_percent(value):
	smooth_percent = value
	mat.set_shader_param("smooth_percent", smooth_percent)
	
func set_texture(value):
	$TextureRect.texture = load("res://ui/transitions/wipe_" + value + ".png")

func play(direction="hide"):
	match direction:
		"hide":
			anim.play("hide")
		"show":
			anim.play_backwards("hide")
