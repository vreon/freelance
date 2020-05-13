extends CanvasLayer

onready var health = $PlayerHealth
onready var tween = $PlayerHealth/Tween
onready var anim = $PlayerHealth/AnimationPlayer

func _ready():
	health.value = global.player_health

func update_health(value):
	if value < health.value:
		anim.play("hurt")
		
	tween.interpolate_property(health, "value", health.value, value, 0.75, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	if not tween.is_active():
		tween.start()

func _on_Lance_health_changed(value):
	update_health(value)

func _on_Tween_tween_completed(object, key):
	anim.play("idle")
