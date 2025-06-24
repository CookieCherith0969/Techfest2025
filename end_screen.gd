extends Node2D

@onready var fade_rect: ColorRect = $Fade/FadeRect

func _ready() -> void:
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(fade_rect,"modulate",Color.TRANSPARENT,1.5)
	await fade_tween.finished
	if name == "EndScreen":
		Engine.time_scale = 3.0
