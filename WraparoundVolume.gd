extends Area2D

export var offset = -400

func _on_body_entered(body):
	if sign(body.velocity.x) != sign(offset):
		body.position.x += offset