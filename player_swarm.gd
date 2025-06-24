class_name PlayerSwarm
extends CharacterBody2D

static var instance: PlayerSwarm

@export
var fade_rect: ColorRect

@onready var collision_shape_2d = $CollisionShape2D
@onready var charge_cooldown_timer = $ChargeCooldownTimer
@onready var ring_sprite = $RingSprite
@onready var camera_2d = $Camera2D
@onready var charge_ring = $RingSprite/ChargeRing

var charge_cooldown_length: float = 1.5
var charge_windup_time: float = 0.3
var charge_lockout_time: float = 0.5

var mouse_moving: bool = false
var charging: bool = false

var deceleration: float = 50.0
var acceleration: float = 140.0
var max_speed: float = 150.0
var charge_speed: float = 300.0

var num_people: int = 0:
	set(value):
		num_people = value
		GameManager.update_num_people(num_people)
var swarming_people: Array[SwarmPerson] = []
var area_per_person: float = 800

const inactive_color: Color = Color.WEB_GRAY
const active_color: Color = Color.WHITE
var base_zoom: float = 0.2
var radius_zoom_ratio: float = 0.01
var target_zoom: float = 1.0
var zoom_smooth_speed: float = 0.6
var active: bool = false

var using_mouse: bool = true

func _ready():
	instance = self

func _input(event):
	if event is InputEventMouse:
		using_mouse = true
	for action in ["Left","Right","Up","Down"]:
		if event.is_action_pressed(action):
			using_mouse = false
	if !active:
		return
	if event.is_action_pressed("MouseMove"):
		mouse_moving = true
	elif event.is_action_released("MouseMove"):
		mouse_moving = false
	
	if event.is_action_pressed("Charge") and charge_cooldown_timer.is_stopped():
		charge()

func charge():
	charging = true
	charge_cooldown_timer.start(charge_cooldown_length)
	charge_ring.value = 0.0
	var recharge_tween: Tween = create_tween()
	recharge_tween.tween_property(charge_ring,"value",1.0,charge_cooldown_length)
	ring_sprite.modulate = inactive_color
	await get_tree().create_timer(charge_windup_time).timeout
	var charge_dir: Vector2
	if using_mouse:
		charge_dir = get_local_mouse_position().normalized()
	else:
		charge_dir = Input.get_vector("Left","Right","Up","Down")
	if !charge_dir:
		charge_dir = velocity.normalized()
	velocity = charge_dir*charge_speed
	for person in swarming_people:
		person.velocity += charge_dir*charge_speed
	await get_tree().create_timer(charge_lockout_time).timeout
	charging = false
	ring_sprite.modulate = active_color

func _physics_process(delta: float):
	if !active:
		return
	var new_zoom = move_toward(camera_2d.zoom.x,target_zoom, zoom_smooth_speed*delta)
	camera_2d.zoom = Vector2(new_zoom, new_zoom)
	
	if charging:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration*delta)
		var collision = move_and_collide(velocity*delta)
		if !collision:
			return
			
		var object = collision.get_collider()
		if object is DestructibleObject:
			if object.min_destroy_count <= num_people:
				object.destroy()
				for i in object.destroy_tax:
					var person_index: int = randi_range(0, swarming_people.size()-1)
					var removed_person: SwarmPerson = swarming_people[person_index]
					swarming_people.remove_at(person_index)
					removed_person.fling_remove()
					num_people -= 1
				update_radius()
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
	target_zoom = (1 / (base_zoom + new_radius*radius_zoom_ratio))

func add_person(new_person: SwarmPerson):
	swarming_people.append(new_person)
	num_people += 1
	update_radius()

func update_radius():
	var new_area: float = area_per_person * num_people
	set_radius(sqrt(new_area/PI))

func _on_pickup_area_body_entered(body):
	if body is SwarmPerson and !body.swarming:
		body.swarming = true
		add_person(body)
		if body.name == "King":
			fade_to_end()

func fade_to_end():
	GameManager.hide()
	GameManager.stop_timing()
	active = false
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(fade_rect,"modulate",Color.WHITE,1.5)
	await fade_tween.finished
	get_tree().change_scene_to_file.call_deferred("res://end_screen.tscn")

func fade_to_fail():
	GameManager.hide()
	GameManager.stop_timing()
	active = false
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(fade_rect,"modulate",Color.WHITE,1.5)
	await fade_tween.finished
	get_tree().change_scene_to_file.call_deferred("res://fail_screen.tscn")

func _on_charge_cooldown_timer_timeout():
	ring_sprite.modulate = active_color
