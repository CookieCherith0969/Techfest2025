extends Node

@onready var game_music = $GameMusic
@onready var title_music = $TitleMusic


func fade_to_game_music():
	game_music.play()
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(game_music,"volume_db",-12.0,2.0)
	fade_tween.parallel().tween_property(title_music,"volume_db",-80.0,2.0)

func fade_to_title_music():
	title_music.play()
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(title_music,"volume_db",0.0,2.0)
	fade_tween.parallel().tween_property(game_music,"volume_db",-80.0,2.0)
