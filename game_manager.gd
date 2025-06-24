extends CanvasLayer

@onready var score_label = $ScoreLabel
@onready var time_label = $TimeLabel
@onready var people_label = $PeopleLabel

var game_length: float = 120.0
var time_remaining: float = game_length
var score: int = -1

var score_per_second: float = 1.0

var counting_down: bool = false

func _ready():
	hide()

func add_score(amount: int):
	score += amount
	score_label.text = "SCORE: "+str(score)

func reset():
	time_remaining = game_length
	time_label.text = "TIME: "+str(ceili(time_remaining))
	score = -1
	score_label.text = "SCORE: "+str(score)

func start_timing():
	counting_down = true

func stop_timing():
	counting_down = false
	add_score(ceili(time_remaining*score_per_second))

func _process(delta):
	if !counting_down:
		return
	time_remaining -= delta
	if time_remaining <= 0.0:
		time_remaining = 0.0
		stop_timing()
		PlayerSwarm.instance.fade_to_fail()
	time_label.text = "TIME: "+str(ceili(time_remaining))

func update_num_people(new_people: int):
	people_label.text = str(new_people)
