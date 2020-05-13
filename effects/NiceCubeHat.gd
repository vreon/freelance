extends Node2D

var velocity = Vector2(
	-((30 * randf()) + 100),
	(100 * randf()) - 50
)
var age = 0

const MAX_AGE = 1
const GRAVITY = 5

onready var sprite = $Sprite

func _ready():
	$AnimationPlayer.play("default")

func _process(delta):
	sprite.position.x += velocity.x * delta
	sprite.position.y += velocity.y * delta
	age += delta
	
	velocity.y += GRAVITY
	
	if age >= MAX_AGE:
		self.queue_free()
