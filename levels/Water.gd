extends Area2D

tool

func _ready():
	# TODO: Uhhh I guess shaders are shared, so setting param here is useless
	$ColorRect.get_material().set_shader_param("height", $ColorRect.rect_size.y)