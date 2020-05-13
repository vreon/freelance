extends Node

var current_scene = null
const DEBUG_BUTTON = 10  # Select
# const DEBUG_BUTTON = 16  # Home

var player_health = 100

export var debug_overlays = false

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	
	InputMap.add_action("debug")
	var debug_event = InputEventJoypadButton.new()
	debug_event.device = 0
	debug_event.button_index = DEBUG_BUTTON
	InputMap.action_add_event("debug", debug_event)
	
func _unhandled_input(event):
	if Input.is_action_pressed("debug"):
		if event is InputEventJoypadButton and event.pressed:
			match event.button_index:
				8:  # Left stick
					debug_overlays = not debug_overlays
					print("Debug overlays ", "on" if debug_overlays else "off")
				12: # D-Pad up
					OS.window_fullscreen = !OS.window_fullscreen
				13: # D-Pad down
					var music_bus_idx = AudioServer.get_bus_index("Music")
					var volume_db = floor(AudioServer.get_bus_volume_db(music_bus_idx))

					if volume_db == 0:
						volume_db = -10
					elif volume_db <= -10 and volume_db > -1000:
						volume_db = -1000
					else:
						volume_db = 0
					
					AudioServer.set_bus_volume_db(music_bus_idx, volume_db)
					print("Music volume: %d dB" % volume_db)
				14: # D-Pad left
					transition_to_scene("res://levels/debug/DebugRoom.tscn", null, "rect")
				15:
					global.player_health = 100
					get_tree().get_nodes_in_group("player")[0].emit_signal("health_changed", 100)
				DEBUG_BUTTON:
					pass
				_:
					print("Pressed button ", event.button_index)
	
func transition_to_scene(path, player_position=null, texture="r"):
	Transition.duration = 0.5
	Transition.smooth_percent = 0.01
	Transition.texture = texture
	Transition.play()
	yield(Transition.get_node("AnimationPlayer"), "animation_finished")
	Transition.play("show")
	Transition.smooth_percent = 0.01
	call_deferred("_deferred_transition_to_scene", path, player_position)

func _deferred_transition_to_scene(path, player_position):
	# Immediately free the current scene,
	# there is no risk here.
	current_scene.free()

	# Load new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instance()

	# Add it to the active scene, as child of root.
	get_tree().get_root().add_child(current_scene)

	# Optional, to make it compatible with the SceneTree.change_scene() API.
	get_tree().set_current_scene(current_scene)
	
	# If a player position was specified, move the player to that node
	# We special case Spawn because Godot won't stop complaining about it
	if player_position and not player_position == "Spawn":
		var players = get_tree().get_nodes_in_group("player")
		
		if players.size() < 1:
			return
		
		var player = players[0]
		var node = current_scene.get_node(player_position)
		
		if node:
			player.position = node.position
