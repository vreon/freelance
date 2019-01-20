extends Node2D

func _ready():
	GlobalMusic.playing = false
	$GUI/WorldName.text = "World 1-1"
	$GUI/LevelName.text = "Grassland"