class_name DestructibleObject
extends StaticBody2D

signal destroyed

@export
var min_destroy_count: int = 5
@export
var destroy_tax: int = 0
@export
var point_value: int = 0

func destroy():
	for child in get_children():
		if child is CPUParticles2D:
			child.reparent(get_parent())
			child.emitting = true
	destroyed.emit()
	GameManager.add_score(point_value)
	queue_free()
