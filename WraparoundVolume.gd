extends Area2D

export(bool) var wrap_vertical = false
export(bool) var wrap_horizontal = true

onready var shape = $CollisionShape2D.shape

func _on_WraparoundVolume_body_exited(body):
	if wrap_horizontal and body.position.x <= position.x - shape.extents.x:
		body.position.x = position.x + shape.extents.x - 1
		
	if wrap_horizontal and body.position.x >= position.x + shape.extents.x:
		body.position.x = position.x - shape.extents.x + 1
		
	if wrap_vertical and body.position.y <= position.y - shape.extents.y:
		body.position.y = position.y + shape.extents.y - 1
		
	if wrap_vertical and body.position.y >= position.y + shape.extents.y:
		body.position.y = position.y - shape.extents.y + 1