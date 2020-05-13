extends Area2D

class_name WrapAroundArea2D

export(bool) var wrap_vertical = false
export(bool) var wrap_horizontal = true

onready var shape = $CollisionShape2D.shape

func _ready():
	connect("body_exited", self, "_on_body_exited")

func _on_body_exited(body):
	if wrap_horizontal:
		if body.position.x <= position.x - shape.extents.x:
			body.position.x = position.x + shape.extents.x - 1
		
		if body.position.x >= position.x + shape.extents.x:
			body.position.x = position.x - shape.extents.x + 1
		
	if wrap_vertical:
		if body.position.y <= position.y - shape.extents.y:
			body.position.y = position.y + shape.extents.y - 1
		
		if body.position.y >= position.y + shape.extents.y:
			body.position.y = position.y - shape.extents.y + 1
