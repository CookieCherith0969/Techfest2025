extends Node2D

@onready var fade_rect: ColorRect = $Fade/FadeRect

func _ready() -> void:
	fade_rect.show()
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(fade_rect,"modulate",Color.TRANSPARENT,1.5)
	await fade_tween.finished
	fade_rect.hide()
	if name == "EndScreen":
		Engine.time_scale = 3.0


func _on_button_pressed():
	Engine.time_scale = 1.0
	GameManager.reset()
	get_tree().change_scene_to_file("res://test_scene.tscn")
