extends Area2D

class_name Hurtbox

enum DamageType {
	PHYSICAL,
	SPIKE,
	BURN,
	SHOCK,
	NONE,
}

enum DamageResult {
	DEALT,
	DEFLECTED,
	IGNORED,
}

export(float) var damage_amount = 20
export(DamageType) var damage_type = DamageType.PHYSICAL
export(float) var hitstun_force = 150

func _ready():
	for player in get_tree().get_nodes_in_group("player"):
		connect("body_entered", player, "_on_hurtbox_entered", [self])
