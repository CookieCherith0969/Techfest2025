extends Label

func _ready():
	var time_score: int = ceili(GameManager.score_per_second*GameManager.time_remaining)
	text = "TIME LEFT: "+str(GameManager.time_remaining).left(5)+" (+"+str(time_score)+" SCORE)"
