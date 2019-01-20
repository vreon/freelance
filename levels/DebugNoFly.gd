extends Node2D

func _ready():
	GlobalMusic.playing = false
	$GUI/WorldName.text = "Debug World"
	$GUI/LevelName.text = "No-Fly Zone Test"