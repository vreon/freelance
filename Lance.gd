extends KinematicBody2D

signal health_changed

# Kirby-like
# const GROUND_MOVE_FORCE = 5
# const AIR_MOVE_FORCE = 5
# const AIR_FRICTION = 0.01
# const GROUND_FRICTION = 0.1
# const MAX_AIR_SPEED = 170
# const MAX_GROUND_SPEED = 100
# const HITSTUN_SPEED = 170
# const FLAP_DECELERATE_FACTOR = 0.5

# Joust-like
const GROUND_MOVE_FORCE = 4
const AIR_MOVE_FORCE = 3
const AIR_FRICTION = 0.001
const GROUND_FRICTION = 0.04
const MAX_AIR_SPEED = 200
const MAX_GROUND_SPEED = 200
const HITSTUN_SPEED = 150
const FLAP_DECELERATE_FACTOR = 1.0
const SKID_FACTOR = 0.95

var gravity = Vector2(0, 300)
var drag = AIR_FRICTION
var jump_force = 170
var flap_force = 115
const MAX_FALL_SPEED = 200
const FALL_START_SPEED = 75  # For animation and sound only
const HITSTUN_DURATION = 0.3

# When and how hard to bounce off of the floor
const FLOOR_BOUNCE_SPEED = MAX_AIR_SPEED * (1 - AIR_FRICTION)
const FLOOR_BOUNCE_FACTOR = 0.4

# When and how hard to bounce off of a wall
const WALL_BOUNCE_SPEED = 150
const WALL_BOUNCE_FACTOR = 0.5

# When Lance successfully attacks an enemy, make him ignore hurtboxes for
# a very brief period. This seems to help with the "attacking an enemy still
# hurts Lance" problem, even though Lance already ignores PHYSICAL damage
# while entering a hurtbox. Hmm...
const ATTACK_INVULNERABILITY_DURATION = 0.1

# TODO ideas
# Don't allow AIR_MOVE_FORCE until the first flap
# Variable jump height (from ground) based on button hold (like Mario)


# Various states
var on_ceiling = false
var on_floor = false
var on_wall = false
var was_on_ceiling = false
var was_on_floor = false
var was_on_wall = false
var pressing_move = false
var attacking = false
var door = null
var can_fly = true
var can_move = true

var velocity = Vector2(0, 0)
var facing_dir = 1
var hitstunned = 0
var attack_invulnerability_timer = 0

var spark_scene = load("res://effects/Spark.tscn")

onready var anim_player = $AnimationPlayer
onready var sprite = $Sprite
onready var attack_trail = $AttackTrail

func _physics_process(delta):
	anim_player.playback_speed = 1
	
	# TODO: with snap
	var true_velocity = move_and_slide(velocity, Vector2(0, -1))
	
	on_ceiling = is_on_ceiling()
	on_floor = is_on_floor()
	on_wall = is_on_wall()
	
	if on_floor:
		if !was_on_floor:
			if abs(velocity.y) >= FLOOR_BOUNCE_SPEED:
				$Hit.play()
				velocity.y *= -FLOOR_BOUNCE_FACTOR
			elif abs(velocity.y) >= FALL_START_SPEED:
				$Land.play()
		else:
			velocity.y = 0
			
	if on_ceiling:
		if !was_on_ceiling:
			if abs(velocity.y) >= FLOOR_BOUNCE_SPEED:
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
	
	# Capture the player's intent
	
	var jump_speed = 0
	pressing_move = false
	
	if can_move and not hitstunned and Input.is_action_pressed("move_left"):
		pressing_move = true
		facing_dir = -1
	
	if can_move and not hitstunned and Input.is_action_pressed("move_right"):
		pressing_move = true
		facing_dir = 1
	
	if can_move and not hitstunned and not on_floor and Input.is_action_just_pressed("drop"):
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
	
	if can_move and not hitstunned and (Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("move_up")):
		attacking = false
		
		if on_floor:
			jump_speed = jump_force
			$Jump.play()
			play_anim("flap")
		elif can_fly:
			jump_speed = flap_force
			$Flap.play()
			play_anim("flap")
			
			# Flapping may help you kill off unwanted horizontal velocity
			if sign(velocity.x) != facing_dir:
				velocity.x *= FLAP_DECELERATE_FACTOR
	elif can_move:
		if on_floor:
			if abs(velocity.x) > 1:
				play_anim("walk")
				anim_player.playback_speed = max(abs(velocity.x / 80), 0.5)  # TODO: lerp
				if sign(velocity.x) != facing_dir:
					anim_player.playback_speed *= -1
			else:
				play_anim("idle")
		elif anim_player.current_animation != "flap" and abs(velocity.y) >= FALL_START_SPEED:
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
		velocity *= (1 - drag)
		
	if on_floor and sign(velocity.x) != facing_dir:
		velocity.x *= SKID_FACTOR

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
	elif hitstunned:
		var mod = (int(hitstunned * 100) % 2) * 0.3 + 0.2
		sprite.modulate = Color(1.0, mod, mod)
	else:
		sprite.modulate = Color(1.0, 1.0, 1.0)

	# Bookkeeping
	
	if abs(velocity.x) <= 1:
		velocity.x = 0
	
	if velocity.y <= 0:
		attacking = false

	hitstunned = max(0, hitstunned - delta)
	attack_invulnerability_timer = max(0, attack_invulnerability_timer - delta)
	
	$DebugStuff.visible = global.debug_overlays
	$DebugStuff/DebugVelocityLine.points[1] = velocity
	$DebugStuff/DebugVelocityLine2.points[1] = true_velocity
	$DebugStuff/DebugVelocityLabel.text = str(velocity)
	
	was_on_floor = on_floor
	was_on_wall = on_wall
	was_on_ceiling = on_ceiling
	
func _on_hurtbox_entered(body, hurtbox):
	if body != self:
		return

	hurt(
		hurtbox.damage_amount,
		hurtbox.damage_type,
		hurtbox.get_global_transform().origin,
		hurtbox.hitstun_force
	)
	
func hurt(amount, type=Hurtbox.DamageType.PHYSICAL, origin=null, force=0):
	if (
		hitstunned or
		(attacking and type == Hurtbox.DamageType.PHYSICAL) or
		(type == Hurtbox.DamageType.NONE) or
		(attack_invulnerability_timer > 0)
	):
		return Hurtbox.DamageResult.IGNORED

	$Ouch.play()
	
	match type:
		Hurtbox.DamageType.BURN:
			$Burned.play()
		Hurtbox.DamageType.SHOCK:
			$Shocked.play()
	
	if origin:
		velocity = (get_global_transform().origin - origin).normalized() * force
		$DebugStuff/HitstunLine.points[1] = velocity

	hitstunned = HITSTUN_DURATION
	
	global.player_health -= amount
	emit_signal("health_changed", global.player_health)
	return Hurtbox.DamageResult.DEALT

func handle_collision(collider, position):
	var damage_result = null
	
	if on_floor and attacking and collider.has_method("hurt"):
		damage_result = collider.hurt(20, Hurtbox.DamageType.PHYSICAL)
		match damage_result:
			Hurtbox.DamageResult.DEALT:
				$Attack.play()
				var spark = spark_scene.instance()
				get_parent().add_child(spark)
				spark.position = position
				attack_invulnerability_timer = ATTACK_INVULNERABILITY_DURATION
			Hurtbox.DamageResult.DEFLECTED:
				$ShieldHit.play()
				var spark = spark_scene.instance()
				spark.scale = Vector2(0.5, 0.5)
				spark.modulate = Color(1.0, 1.0, 1.0, 0.5)
				get_parent().add_child(spark)
				spark.position = position
				attack_invulnerability_timer = ATTACK_INVULNERABILITY_DURATION

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
		
func _on_water_entered(body):
	if body == self:
		$Splash.volume_db = (1 - (velocity.y / MAX_AIR_SPEED)) * -6
		$Splash.play()
		
		gravity *= 0.2
		velocity *= 0.2
		drag *= 2
		jump_force *= 0.2
		flap_force *= 0.5
		
		var lowpass = AudioEffectLowPassFilter.new()
		lowpass.cutoff_hz = 500
		
		var reverb = AudioEffectReverb.new()
		reverb.room_size = 0.3
		reverb.damping = 0.9
		
		AudioServer.add_bus_effect(AudioServer.get_bus_index("Master"), reverb)
		AudioServer.add_bus_effect(AudioServer.get_bus_index("Master"), lowpass)
		
func _on_water_exited(body):
	if body == self:
		gravity /= 0.2
		velocity /= 0.5
		drag /= 2
		jump_force /= 0.2
		flap_force /= 0.5
		
		AudioServer.remove_bus_effect(AudioServer.get_bus_index("Master"), 0)
		AudioServer.remove_bus_effect(AudioServer.get_bus_index("Master"), 0)
		
		$Splash.volume_db = (1 - (velocity.y / MAX_AIR_SPEED)) * -6
		$Splash.play()
