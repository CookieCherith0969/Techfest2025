extends CanvasLayer

var game_length: float = 180.0
var time_remaining: float = game_length
var score: int = 0

var score_per_second: float = 1.0

var counting_down: bool = false

func add_score(amount: int):
	score += amount

func reset():
	time_remaining = game_length
	score = 0

func start_timing():
	counting_down = true

func stop_timing():
	counting_down = false

func _process(delta):
	if !counting_down:
		return
	time_remaining -= delta
	if time_remaining <= 0.0:
		time_remaining = 0.0
		stop_timing()
		PlayerSwarm.instance.fade_to_fail()
