class_name SwarmPerson
extends CharacterBody2D

@onready var wander_timer = $WanderTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var swarming: bool = false:
	set(value):
		swarming = value
		if swarming:
			add_to_group("SwarmingPeople")
			#wander_timer.stop()
		else:
			remove_from_group("SwarmingPeople")
			#wander_timer.start(randf_range(min_wander_time,max_wander_time))

@export
var max_wander_range: float = 6.0
@export
var min_wander_range: float = 1.0
@export
var wander_speed: float = 15.0
@export
var wander_stop_distance: float = 1.0
@export
var min_wander_time: float = 1.2
@export
var max_wander_time: float = 1.8

#@export
#var max_separation_strength: float = 60.0
#@export
#var max_separation_distance_multiplier: float = 0.8
@export
var cohesion_strength: float = 400.0
@export
var separation_strength: float = 1000.0
@export
var separation_distance: float = 30.0

@onready var target_pos: Vector2 = global_position
@onready var wander_offset: Vector2 = Vector2.from_angle(randf_range(0.0,2*PI))*randf_range(min_wander_range,max_wander_range)

var swarm_offset: Vector2 = Vector2.ZERO

const nearby_swarm_check_num: int = 3
var acceleration: float = 60.0
var damping: float = 0.5

var walk_speed_threshold: float = 5.0

func _ready():
	wander_timer.start(randf_range(min_wander_time,max_wander_time))

"""func _physics_process(delta):
	if swarming:
		target_pos = PlayerSwarm.instance.global_position
		target_pos += swarm_offset
	
	if swarming:
		var swarm_velocity: Vector2 = (target_pos+wander_offset) - global_position
		swarm_velocity *= cohesion_strength
		velocity = velocity.move_toward(swarm_velocity, acceleration*delta)
	else:
		if global_position.distance_to(target_pos+wander_offset) > wander_stop_distance:
			velocity = global_position.direction_to(target_pos+wander_offset)*wander_speed
		else:
			velocity = Vector2.ZERO
	
	velocity *= 1 - (damping*delta)
	move_and_slide()"""

func _physics_process(delta):
	if swarming:
		target_pos = PlayerSwarm.instance.global_position
		#target_pos += swarm_offset
	
	if swarming:
		velocity = velocity.move_toward(PlayerSwarm.instance.velocity, acceleration*delta)
		var cohesion_force: Vector2 = target_pos - global_position
		#cohesion_force *= cohesion_strength
		velocity += cohesion_force.normalized()*cohesion_strength*delta
		var nearest_positions: Array[Vector2] = get_nearest_positions()
		for pos in nearest_positions:
			if pos != Vector2.ZERO:
				var separation_force: Vector2 = global_position - pos
				var separation_magnitude: float = 1.0 - (separation_force.length()/separation_distance)
				separation_magnitude *= separation_strength
				separation_force = separation_force.normalized()*separation_magnitude
				velocity += separation_force*delta
	else:
		if global_position.distance_to(target_pos+wander_offset) > wander_stop_distance:
			velocity = global_position.direction_to(target_pos+wander_offset)*wander_speed
		else:
			velocity = Vector2.ZERO
	
	if animation_player.current_animation == "idle" and velocity.length() > walk_speed_threshold:
		animation_player.play("RESET")
		animation_player.seek(1,true)
		animation_player.play("walk")
	elif animation_player.current_animation == "walk" and velocity.length() < walk_speed_threshold:
		animation_player.play("RESET")
		animation_player.seek(1,true)
		animation_player.play("idle")
	#velocity *= 1 - (damping*delta)
	move_and_slide()

func _on_wander_timer_timeout():
	#if swarming:
	#	wander_offset = Vector2.ZERO
	#	return
	wander_offset = Vector2.from_angle(randf_range(0.0,2*PI))*randf_range(min_wander_range,max_wander_range)
	wander_timer.start(randf_range(min_wander_time,max_wander_time))



func get_nearest_positions() -> Array[Vector2]:
	var nearest_positions: Array[Vector2] = []
	var nearest_distances: Array[float] = []
	nearest_positions.resize(nearby_swarm_check_num)
	nearest_distances.resize(nearby_swarm_check_num)
	nearest_distances.fill(-1.0)
	for swarm_person in get_tree().get_nodes_in_group("SwarmingPeople"):
		if swarm_person == self:
			continue
		var person_pos: Vector2 = swarm_person.global_position
		var pos_distance: float = global_position.distance_squared_to(person_pos)
		for i in nearby_swarm_check_num:
			if nearest_distances[i] < 0.0:
				nearest_positions.insert(i, person_pos)
				nearest_distances.insert(i, pos_distance)
				nearest_positions.pop_back()
				nearest_distances.pop_back()
				break
			if pos_distance < nearest_distances[i]:
				nearest_positions.insert(i, person_pos)
				nearest_distances.insert(i, pos_distance)
				nearest_positions.pop_back()
				nearest_distances.pop_back()
				break
	return nearest_positions
