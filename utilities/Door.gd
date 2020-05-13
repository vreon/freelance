extends Node2D

#warning-ignore:unused_class_variable
export var destination_level = "debug/DebugRoom"

#warning-ignore:unused_class_variable
export var destination_position = "Spawn"

func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		body.door = self

func _on_Area2D_body_exited(body):
	if body.is_in_group("player"):
		body.door = null
