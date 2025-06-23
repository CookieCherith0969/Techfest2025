extends Marker2D

const person_scene: PackedScene = preload("res://swarm_person.tscn")

@export
var activate_on_ready: bool = false

@export
var num_people: int = 6
@export
var min_distance: float = 20.0
@export
var max_distance: float = 30.0

@export
var textures: Array[Texture2D] = []

func _ready():
	if activate_on_ready:
		spawn()

func spawn():
	for i in num_people:
		var new_person = person_scene.instantiate()
		var spawn_pos: Vector2 = Vector2.RIGHT.rotated(randf_range(0,2*PI))
		spawn_pos *= randf_range(min_distance, max_distance)
		new_person.position = global_position + spawn_pos
		if textures.size() > 0:
			new_person.texture = textures.pick_random()
		get_tree().current_scene.add_child.call_deferred(new_person)
