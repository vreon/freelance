extends StaticBody2D
tool

const LOOK_AWAY_DISTANCE = 150
export(float, 30, 200, 5) var repel_distance = 50 setget set_repel_distance
export(bool) var show_repel_radius = true setget set_show_repel_radius
const MAX_REPEL_FORCE = 10
const HOVER_AMPLITUDE = 3
const HOVER_FREQUENCY_MSEC = 500

var facing_right = true
var was_facing_right = true
var pointedly_ignoring = false
var was_repelling = false
var repelling = false

var peek_timer = 0
var blink_timer = 0
var start_position_y = 0
var hover_phase = randf() * 2 * PI

onready var sprite = $Sprite
onready var anim = $AnimationPlayer

func _ready():
	anim.play("right")
	start_position_y = position.y
	reset_peek_timer()
	reset_blink_timer()
	
func _draw():
	if repelling or (Engine.is_editor_hint() and show_repel_radius):
		draw_circle(Vector2(0, 0), repel_distance, Color(1.0, 1.0, 1.0, 0.1))
		
func set_repel_distance(new_value):
	repel_distance = new_value
	update()
	
func set_show_repel_radius(new_value):
	show_repel_radius = new_value
	update()

func _process(delta):
	var players = get_tree().get_nodes_in_group("player")
	
	if players.size() < 1:
		return

	var player = players[0]
	var distance = player.position.distance_to(position)
	
	# Casually glance in the direction of the player
	facing_right = player.position.x >= position.x
	
	# Pointedly look the other way if they're too close
	pointedly_ignoring = distance <= LOOK_AWAY_DISTANCE
	repelling = distance <= repel_distance
	
	if pointedly_ignoring:
		facing_right = not facing_right
		
	if repelling and not Engine.is_editor_hint():
		if not was_repelling:
			$Repel.play()
		sprite.modulate = Color(1.5, 1.5, 1.5)
		repel(player)
		update()
	else:
		sprite.modulate = Color(1.0, 1.0, 1.0)
		if was_repelling:
			update()
		
	if was_facing_right and not facing_right:
		anim.play("blink_rtl")
		reset_peek_timer()
		reset_blink_timer()
	elif not was_facing_right and facing_right:
		anim.play("blink_ltr")
		reset_peek_timer()
		reset_blink_timer()
	
	maybe_peek(delta)
	maybe_blink(delta)
	
	if not Engine.is_editor_hint():
		position.y = start_position_y + sin(OS.get_ticks_msec() * (1.0 / HOVER_FREQUENCY_MSEC) + hover_phase) * HOVER_AMPLITUDE
	
	was_facing_right = facing_right
	was_repelling = repelling
	
func repel(player):
	# Get the vector from here to the player
	var to_player = player.position - position
	
	# TODO: inverse square
	# Get the distance (to calculate force effect)
	# var distance = to_player.length()
	
	# Determine the maximal force vector
	var force_vector = to_player.normalized() * MAX_REPEL_FORCE
	
	# TODO: * delta?
	player.velocity += force_vector
	
func maybe_peek(delta):
	peek_timer -= delta
	if peek_timer <= 0:
		if pointedly_ignoring:
			match anim.current_animation:
				"right":
					anim.play("peek_rtl")
				"left":
					anim.play("peek_ltr")
		reset_peek_timer()
		
func maybe_blink(delta):
	blink_timer -= delta
	if blink_timer <= 0:
		match anim.current_animation:
			"right":
				anim.play("blink_right")
			"left":
				anim.play("blink_left")
		reset_blink_timer()
	
func reset_peek_timer():
	peek_timer = 3 + 5 * randf()
	
func reset_blink_timer():
	blink_timer = 3 + 2 * randf()

func _on_AnimationPlayer_animation_finished(anim_name):
	var next = null
	match anim_name:
		"blink_left", "blink_rtl", "peek_ltr":
			next = "left"
		"blink_right", "blink_ltr", "peek_rtl":
			next = "right"
	if next:
		anim.play(next)
		

func attacked():
	return "deflected"
