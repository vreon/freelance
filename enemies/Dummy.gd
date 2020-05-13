extends StaticBody2D

const Hurtbox = preload("res://enemies/Hurtbox.gd")

export(Hurtbox.DamageResult) var attack_damage_result = Hurtbox.DamageResult.IGNORED
export(Hurtbox.DamageType) var touch_damage_type = Hurtbox.DamageType.NONE

func _ready():
	$Hurtbox.damage_type = touch_damage_type

func hurt(_amount=null, _type=null, _origin=null, _force=null):
	return attack_damage_result
