extends Control

var confirmed = false

func _input(event):
	if not confirmed and (event.is_action("jump") or event.is_action("move_up")):
		confirmed = true
		global.transition_to_scene("res://levels/debug/DebugRoom.tscn", null, "rect")
		$Confirm.play()
