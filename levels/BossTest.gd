extends Node2D

func _ready():
	GlobalMusic.play_track(GlobalMusic.tracks.BOSS)
	
const WIND_FORCE = 300

func _process(delta):
	var wind_direction = Vector2(randf() * 2 - 1, randf() * 2 - 1)
	$Lance.velocity += wind_direction * WIND_FORCE * delta
