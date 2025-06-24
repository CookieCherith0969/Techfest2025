extends Label

func _ready():
	var time_taken: float = GameManager.game_length - GameManager.time_remaining
	var time_score: int = ceili(GameManager.score_per_second*GameManager.time_remaining)
	text = "TIME: "+str(time_taken).left(5)+" (+"+str(time_score)+" SCORE)"
