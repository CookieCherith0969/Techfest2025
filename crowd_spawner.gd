extends Marker2D

const person_scene: PackedScene = preload("res://swarm_person.tscn")

@export
var activate_on_ready: bool = true

@export
var num_people: int = 6
@export
var min_distance: float = 20.0
@export
var max_distance: float = 30.0

func _ready():
	if activate_on_ready:
		spawn()

func spawn():
	for i in num_people:
		var new_person = person_scene.instantiate()
		var spawn_pos: Vector2 = Vector2.RIGHT.rotated(randf_range(0,2*PI))
		spawn_pos *= randf_range(min_distance, max_distance)
		new_person.position = position + spawn_pos
		add_sibling.call_deferred(new_person)
