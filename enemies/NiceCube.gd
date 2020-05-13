extends KinematicBody2D

const MAX_HOP_HEIGHT = 150
const MIN_HOP_HEIGHT = 120
const GRAVITY = 5
const GROUND_FRICTION = 0.02

const MAX_HOP_INTERVAL = 10
const MIN_HOP_INTERVAL = 2
const MAX_HOP_INTERVAL_ANGRY = 5
const MAX_SLIDE_INTERVAL = 7
const MIN_SLIDE_INTERVAL = 3

onready var animation_player = $AnimationPlayer
onready var sprite = $Sprite
var hop_timer = 0
var slide_timer = rand_between(MIN_SLIDE_INTERVAL, MAX_SLIDE_INTERVAL)
var velocity = Vector2(0, 0)

var hat_scene = load("res://effects/NiceCubeHat.tscn")
var angry = false
var on_fire = false


func rand_between(min_, max_):
	return (max_ - min_) * randf() + min_


func _ready():
	animation_player.play("idle")
	

func _process(_delta):
	if angry and not animation_player.is_playing():
		animation_player.play("angry")


func become_angry():
	if angry:
		return
	angry = true
	$Jostle.play()
	var instance = hat_scene.instance()
	get_parent().add_child(instance)
	instance.position = position
	animation_player.play("become_angry")
	

func _physics_process(delta):
	hop_timer -= delta
	slide_timer -= delta
	
	move_and_slide(velocity, Vector2(0, -1))
	
	var on_floor = is_on_floor()
	var on_wall = is_on_wall()
	
	if on_floor:
		velocity.x *= (1 - GROUND_FRICTION)
		velocity.y = 0
		
	if on_wall:
		velocity.x *= -1
	
	# Intent here:
	# - Nicecube can hop or slide
	# - Nicecube can't hop while sliding, or slide while in the air (unless angry)
	
	if hop_timer <= 0 and on_floor and angry:
		hop()
	
	if slide_timer <= 0 and (on_floor or angry) and animation_player.current_animation != "become_angry":
		slide()
		
	# WIP WIP WIP switch to hitbox collision
	for i in range(get_slide_count()):
		var collision = get_slide_collision(i)
		if collision.collider.is_in_group("player"):
			collision.collider.handle_collision(self, collision.position)
		
	velocity.y += GRAVITY
	
	sprite.flip_h = velocity.x < 0
	
func hop():
	velocity.y = -rand_between(MIN_HOP_HEIGHT, MAX_HOP_HEIGHT)
	hop_timer = rand_between(MIN_HOP_INTERVAL, MAX_HOP_INTERVAL_ANGRY if angry else MAX_HOP_INTERVAL)
	if angry:
		$FlameDash.play()
	else:
		$Hop.play()
	
func slide():
	var direction = -1 if randi() % 2 else 1
	velocity.x = 200 * direction
	slide_timer = rand_between(MIN_SLIDE_INTERVAL, MAX_SLIDE_INTERVAL)
	if angry:
		$FlameDash.play()
	else:
		$Slide.play()
		
# Called by become_angry animation
func set_on_fire():
	on_fire = true
	$Hurtbox.damage_type = Hurtbox.DamageType.BURN
	$Hurtbox.damage_amount = 30
	$Light2D.visible = true

func hurt(amount, _type=Hurtbox.DamageType.PHYSICAL, _origin=null, _force=0):
	if animation_player.current_animation == "become_angry" and not on_fire:
		return Hurtbox.DamageResult.DEFLECTED

	if not angry:
		become_angry()

	return Hurtbox.DamageResult.IGNORED if on_fire else Hurtbox.DamageResult.DEALT
