class_name PlayerSwarm
extends CharacterBody2D

static var instance: PlayerSwarm

@onready var collision_shape_2d = $CollisionShape2D
@onready var charge_cooldown_timer = $ChargeCooldownTimer
@onready var ring_sprite = $RingSprite

@export var charge_cooldown_length: float = 2.0
@export var charge_windup_time: float = 0.3
@export var charge_lockout_time: float = 0.5

var mouse_moving: bool = false
var charging: bool = false

var deceleration: float = 50.0
var acceleration: float = 140.0
var max_speed: float = 100.0
var charge_speed: float = 200.0

var num_people: int = 0
var swarming_people: Array[SwarmPerson] = []
var area_per_person: float = 800

const inactive_color: Color = Color.WEB_GRAY
const active_color: Color = Color.WHITE

func _ready():
	instance = self

func _input(event):
	if event.is_action_pressed("MouseMove"):
		mouse_moving = true
	elif event.is_action_released("MouseMove"):
		mouse_moving = false
	
	if event.is_action_pressed("Charge") and charge_cooldown_timer.is_stopped():
		charge_cooldown_timer.start(charge_cooldown_length)
		charge()

func charge():
	charging = true
	ring_sprite.modulate = inactive_color
	await get_tree().create_timer(charge_windup_time).timeout
	var charge_dir: Vector2
	if mouse_moving:
		charge_dir = get_local_mouse_position().normalized()
	else:
		charge_dir = Input.get_vector("Left","Right","Up","Down")
	velocity = charge_dir*charge_speed
	for person in swarming_people:
		person.velocity += charge_dir*charge_speed
	await get_tree().create_timer(charge_lockout_time).timeout
	charging = false

func _physics_process(delta: float):
	if charging:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration*delta)
		var collision = move_and_collide(velocity*delta)
		if !collision:
			return
			
		var object = collision.get_collider()
		if object is DestructibleObject:
			if object.min_destroy_count <= num_people:
				object.destroy()
		return
	
	var input_dir: Vector2
	if !mouse_moving:
		input_dir = Input.get_vector("Left","Right","Up","Down")
	else:
		input_dir = get_local_mouse_position().normalized()
	if input_dir:
		velocity = velocity.move_toward(input_dir*max_speed, acceleration*delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration*delta)
	move_and_slide()

func get_radius() -> float:
	return collision_shape_2d.shape.radius

func set_radius(new_radius: float) -> void:
	collision_shape_2d.shape.radius = new_radius
	ring_sprite.scale = Vector2(new_radius/64.0, new_radius/64.0)

func add_person(new_person: SwarmPerson):
	swarming_people.append(new_person)
	num_people += 1
	var new_area: float = area_per_person * num_people
	set_radius(sqrt(new_area/PI))
	
	"""var radius_add: float = 26.0
	var count_add: int = 8
	var pos_radius: float = 0.0
	var total_count: int = 0
	var count: int = 0
	var base_angle: float = 0.0
	var swarm_offsets: Array[Vector2] = [Vector2.ZERO]
	var layer_index: int = 0
	for i in num_people-1:
		if i >= total_count:
			#base_angle = randf_range(0.0, 2*PI)
			pos_radius += radius_add
			count += count_add
			total_count += count
			layer_index = 0
		var new_offset: Vector2 = Vector2.RIGHT*pos_radius
		var offset_angle: float = 0.0
		
		var outer_slots: int = count
		if num_people-1 < total_count:
			var missing_slots: int = total_count - (num_people-1)
			outer_slots = count - missing_slots
		offset_angle = fposmod(base_angle + layer_index*2*PI/outer_slots,2*PI)
		layer_index += 1
		
		swarm_offsets.append(new_offset.rotated(offset_angle))
	
	var index = 0
	for person in swarming_people:
		person.swarm_offset = swarm_offsets[index]
		index += 1"""

func _on_pickup_area_body_entered(body):
	if body is SwarmPerson and !body.swarming:
		body.swarming = true
		add_person(body)


func _on_charge_cooldown_timer_timeout():
	ring_sprite.modulate = active_color
