class_name DestructibleObject
extends StaticBody2D

@onready var destroy_sound = $DestroySound

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
	destroy_sound.reparent(get_parent())
	destroy_sound.play()
	GameManager.add_score(point_value)
	queue_free()
