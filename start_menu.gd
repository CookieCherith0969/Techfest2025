extends CanvasLayer

@onready var modulate_control = $ModulateControl
@export
var instructions_modulate: Control

func _ready():
	instructions_modulate.modulate = Color.TRANSPARENT

func _on_button_pressed():
	SoundManager.fade_to_game_music()
	var start_tween: Tween = create_tween()
	start_tween.tween_property(modulate_control,"modulate",Color.TRANSPARENT,1.5)
	start_tween.tween_callback(give_control)

func give_control():
	var instruction_tween: Tween = create_tween()
	instruction_tween.tween_property(instructions_modulate,"modulate",Color.WHITE,1.5)
	hide()
	PlayerSwarm.instance.active = true
	GameManager.show()
	GameManager.start_timing()
