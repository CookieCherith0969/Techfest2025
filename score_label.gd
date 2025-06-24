extends Label

func _ready():
	text = "SCORE: "+str(GameManager.score)
