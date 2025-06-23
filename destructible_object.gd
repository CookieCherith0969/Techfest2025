class_name DestructibleObject
extends StaticBody2D

signal destroyed

@export
var min_destroy_count: int = 5

func destroy():
	for child in get_children():
		if child is CPUParticles2D:
			child.reparent(get_parent())
			child.emitting = true
	destroyed.emit()
	queue_free()
