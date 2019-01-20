extends KinematicBody2D

signal health_changed

# Kirby-like
# const GROUND_MOVE_FORCE = 5
# const AIR_MOVE_FORCE = 5
# const AIR_FRICTION = 0.01
# const GROUND_FRICTION = 0.1
# const MAX_AIR_SPEED = 170
# const MAX_GROUND_SPEED = 100
# const FLAP_DECELERATE = true

# Joust-like
const GROUND_MOVE_FORCE = 2
const AIR_MOVE_FORCE = 3
const AIR_FRICTION = 0.001
const GROUND_FRICTION = 0.01
const MAX_AIR_SPEED = 200
const MAX_GROUND_SPEED = 200
const FLAP_DECELERATE = false

var gravity = Vector2(0, 300)
const JUMP_FORCE = 170
const FLAP_FORCE = 115
const MAX_FALL_SPEED = 200
const HITSTUN_DURATION = 0.3

# When and how hard to bounce off of the floor
const FLOOR_BOUNCE_SPEED = MAX_AIR_SPEED * (1 - AIR_FRICTION)
const FLOOR_BOUNCE_FACTOR = 0.5

# When and how hard to bounce off of a wall
const WALL_BOUNCE_SPEED = 100
const WALL_BOUNCE_FACTOR = 0.8

# TODO ideas
# Don't allow AIR_MOVE_FORCE until the first flap
# Variable jump height (from ground) based on button hold (like Mario)

# Various states
var on_floor = false
var on_wall = false
var was_on_floor = false
var was_on_wall = false
var pressing_move = false
var attacking = false
var door = null
var can_fly = true
var can_move = true

var velocity = Vector2(0, 0)
var facing_dir = 1
var hitstun = 0

var spark_scene = load("res://effects/Spark.tscn")

onready var anim_player = $AnimationPlayer
onready var sprite = $Sprite
onready var attack_trail = $AttackTrail

func _ready():
	# XXX: Particle2D on HTML5 causes rendering to stop until particles are dead, wtf
	if OS.get_name() != "HTML5":
		attack_trail.visible = true
	
func _physics_process(delta):
	anim_player.playback_speed = 1
	
	# TODO: with snap
	var true_velocity = move_and_slide(velocity, Vector2(0, -1))
	
	on_floor = is_on_floor()
	on_wall = is_on_wall()
	
	# Capture the player's intent
	
	var jump_speed = 0
	pressing_move = false
	
	if can_move and not hitstun and Input.is_action_pressed("move_left"):
		pressing_move = true
		facing_dir = -1
	
	if can_move and not hitstun and Input.is_action_pressed("move_right"):
		pressing_move = true
		facing_dir = 1
	
	if can_move and not hitstun and not on_floor and Input.is_action_just_pressed("drop"):
		attacking = true
		velocity.y = MAX_FALL_SPEED
		$Drop.play()

	if can_move and door and Input.is_action_just_pressed("move_up"):
		global.transition_to_scene("res://levels/" + door.destination_level + ".tscn", door.destination_position, "radial")
		can_move = false
		velocity = Vector2(0, 0)
		gravity = Vector2(0, 0)
		# TODO: Play anim enter door
		$Door.play()
	
	if can_move and not hitstun and (Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("move_up")):
		attacking = false
		
		if on_floor:
			jump_speed = JUMP_FORCE
			$Jump.play()
			play_anim("flap")
		elif can_fly:
			jump_speed = FLAP_FORCE
			$Flap.play()
			play_anim("flap")
			
			# Flapping helps you kill off unwanted horizontal velocity
			if FLAP_DECELERATE and sign(velocity.x) != facing_dir:
				velocity.x *= 0.5
	elif can_move:
		if on_floor:
			if abs(velocity.x) > 1:
				play_anim("walk")
				anim_player.playback_speed = velocity.x / 50  # TODO: lerp
			else:
				play_anim("idle")
		elif anim_player.current_animation != "flap":
			play_anim("fall")

	
	# ... collisions
	

	# for i in range(get_slide_count()):
	if get_slide_count() > 0:
		var collision = get_slide_collision(0)
		handle_collision(collision.collider, collision.position)
		
	# Update velocity based on environmental factors...

	# ... drag
	if on_floor and not pressing_move:
		velocity.x *= (1 - GROUND_FRICTION)
	else:
		velocity *= (1 - AIR_FRICTION)

	# ... gravity
	velocity += gravity * delta
		
	# Apply "move" force (left-and-right force from player input)
	
	if pressing_move:
		var move_force = GROUND_MOVE_FORCE if on_floor else AIR_MOVE_FORCE
		velocity.x += move_force * facing_dir

	# Oddly, bleeding off excess Y velocity makes Lance feel ungainly
	# So, if jumping or flapping, instantly set the velocity
	if jump_speed:
		velocity.y = -jump_speed

	# And clamp it to reasonable limits

	var max_speed = MAX_GROUND_SPEED if on_floor else MAX_AIR_SPEED
	velocity.x = clamp(velocity.x, -max_speed, max_speed)
	velocity.y = clamp(velocity.y, -MAX_FALL_SPEED, MAX_FALL_SPEED)
	
	# Visual updates
	
	attack_trail.emitting = attacking
	sprite.flip_h = facing_dir == -1
	
	# TODO: clumsy
	if door:
		sprite.modulate = Color(0.8, 0.8, 0.8)
	elif hitstun:
		var mod = (int(hitstun * 100) % 2) * 0.3 + 0.2
		sprite.modulate = Color(1.0, mod, mod)
	else:
		sprite.modulate = Color(1.0, 1.0, 1.0)

	# Bookkeeping
	
	if abs(velocity.x) <= 1:
		velocity.x = 0
	
	if velocity.y <= 0:
		attacking = false

	hitstun = max(0, hitstun - delta)
	
	$DebugStuff.visible = global.debug_overlays
	$DebugStuff/DebugVelocityLine.points[1] = velocity
	$DebugStuff/DebugVelocityLine2.points[1] = true_velocity
	$DebugStuff/DebugVelocityLabel.text = str(velocity)
	
	was_on_floor = on_floor
	was_on_wall = on_wall

func handle_collision(collider, position):
	var attack_result = null
	var touch_result = null
	
	if on_floor and attacking and collider.has_method("attacked"):
		attack_result = collider.attacked()
		match attack_result:
			true, "attacked":
				$Attack.play()
				var spark = spark_scene.instance()
				get_parent().add_child(spark)
				spark.position = position
			false, "deflected":
				$ShieldHit.play()
				var spark = spark_scene.instance()
				spark.scale = Vector2(0.5, 0.5)
				spark.modulate = Color(1.0, 1.0, 1.0, 0.5)
				get_parent().add_child(spark)
				spark.position = position
	
	if not hitstun and (not attacking or attack_result == "touched") and collider.has_method("touched"):
		touch_result = collider.touched()
		match touch_result:
			"hurt", "burned", "shocked":
				$Ouch.play()
				velocity = (self.position - position).normalized() * MAX_AIR_SPEED
				hitstun = HITSTUN_DURATION
				continue
			"hurt":
				# TODO: get damage amount from collider
				take_damage(20)
			"burned":
				$Burned.play()
				take_damage(30)
			"shocked":
				$Shocked.play()
				take_damage(30)
		
	if not touch_result or touch_result == "none":
		# Hit a bog-standard collider.
		# Find out how fast we were going, and whether
		# we need to bounce or what.
		
		if on_floor:
			if !was_on_floor:
				if velocity.y >= FLOOR_BOUNCE_SPEED:
					$Hit.play()
					velocity.y *= -FLOOR_BOUNCE_FACTOR
				else:
					$Land.play()
			else:
				velocity.y = 0
				
		if !was_on_wall and on_wall:
			if abs(velocity.x) > WALL_BOUNCE_SPEED:
				$Hit.play()
				velocity.x *= -WALL_BOUNCE_FACTOR
		elif on_wall:
			velocity.x = 0
			
func take_damage(amount):
	global.player_health -= amount
	emit_signal("health_changed", global.player_health)

func play_anim(anim_name):
	if anim_player.is_playing() and anim_player.current_animation == anim_name:
		return
	anim_player.play(anim_name)

func _on_no_fly_zone_entered(body):
	if body == self:
		can_fly = false
		
func _on_no_fly_zone_exited(body):
	if body == self:
		can_fly = true