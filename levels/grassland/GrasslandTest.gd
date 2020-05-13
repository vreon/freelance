extends Node2D

func _ready():
	GlobalMusic.play_track(GlobalMusic.tracks.GRASS)
	$GUI/WorldName.text = "World 1-1"
	$GUI/LevelName.text = "Grassland"
