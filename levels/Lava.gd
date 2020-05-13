extends TileMap

var damage_amount = 30
var damage_type = Hurtbox.DamageType.BURN
var hitstun_force = 150

func _ready():
	for player in get_tree().get_nodes_in_group("player"):
		connect("body_entered", player, "_on_hurtbox_entered", [self])
