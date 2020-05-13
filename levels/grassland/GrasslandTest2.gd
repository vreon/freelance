extends Node2D

var scroll_speed = 20
var scroll_delay_timer = 3

onready var scroll = $Path2D/PathFollow2D
onready var scroll_alert_anim = $GUI/scroll_alert/AnimationPlayer

func _ready():
	GlobalMusic.play_track(GlobalMusic.tracks.GRASS)
	$GUI/WorldName.text = "World 1-1"
	$GUI/LevelName.text = "Grassland"
	scroll_alert_anim.play("go")
	
func _process(delta):
	scroll_delay_timer -= delta
	
	if scroll_delay_timer < 0:
		scroll.offset += scroll_speed * delta
