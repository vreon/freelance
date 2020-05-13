extends KinematicBody2D

export var max_speed = Vector2(200, 60)
export var accel_magnitude = 100
export var follow_distance = 100
export(float) var follow_multiplier = 1
export var squirreliness_min = 0
export var squirreliness_max = 5
export(Texture) var texture

var velocity = Vector2(0, 0)
var gravity = Vector2(0, 0)
var accel_direction = Vector2(0, 0)
var direction_timer = 0

onready var sprite = $Sprite
onready var hurtbox = $Hurtbox
onready var player = $"../Lance"
onready var anim = $AnimationPlayer

func _ready():
	anim.play("flap")
	
	if texture:
		$Sprite.texture = texture
	
func _process(delta):
	sprite.flip_h = accel_direction.x > 0
	hurtbox.scale = Vector2(-1 if sprite.flip_h else 1, 1)

	$DebugStuff.visible = global.debug_overlays
	if global.debug_overlays:
		$DebugStuff/DebugVelocityLine.points[1] = velocity
		$DebugStuff/DebugAccelerationLine.points[1] = accel_direction * accel_magnitude
		
	# Normally this enemy will be moving at its max speed, so we can assume
	# the slower it's moving, the harder it's trying to speed up
	anim.playback_speed = min(max(max_speed.x, max_speed.y) / velocity.length(), 8)

func _physics_process(delta):
	move_and_slide(velocity, Vector2(0, -1))
	
	# Bounce around randomly
	direction_timer -= delta
	if direction_timer <= 0:
		direction_timer = randf() * (squirreliness_max - squirreliness_min) + squirreliness_min
		accel_direction = randvec2()
		
	# If the player is nearby, try to attack them (by accelerating toward their head)
	var current_accel_magnitude = accel_magnitude
	if player and position.distance_to(player.position) < follow_distance:
		accel_direction = ((player.position + Vector2(0, -5)) - position).normalized()
		current_accel_magnitude *= follow_multiplier
	
	velocity += gravity * delta
	velocity += accel_direction * current_accel_magnitude * delta
	velocity.x = clamp(velocity.x, -max_speed.x, max_speed.x)
	velocity.y = clamp(velocity.y, -max_speed.y, max_speed.y)
	
	if is_on_wall():
		velocity.x *= -0.8
		accel_direction.x *= -1
		
	if is_on_floor() or is_on_ceiling():
		velocity.y *= -0.8
		accel_direction.y *= -1

func randvec2():
	return Vector2(0, 1.0).rotated(randf() * 2 * PI)
