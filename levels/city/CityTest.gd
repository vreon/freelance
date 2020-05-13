extends Node2D

func _ready():
	GlobalMusic.play_track(GlobalMusic.tracks.CHILL)
	$GUI/WorldName.text = "World 3-1"
	$GUI/LevelName.text = "Moonshine"
