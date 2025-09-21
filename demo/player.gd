class_name Player

extends Area2D

signal health_changed(new_health)
signal experience_changed(new_experience, new_level, new_max_xp)
signal level_up(new_level)
signal boosting_changed(is_boosting)

@export var thrust_accel = 800.0
@export var max_speed = 400.0
const DEFAULT_MAX_SPEED = 400.0
@export var friction = 600.0
@export var rotation_speed = 5.0

@export var fire_cd := 0.5
const DEFAULT_FIRE_CD := 0.5
var can_fire := true

var screen_size # Size of the game window.
var velocity = Vector2.ZERO

var current_health = 3
const DEFAULT_HEALTH = 3

@export var max_xp := 100
var max_xp_increase := 100
var current_xp = 0
var current_level := 1

var boosting = false

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	hide()
	connect("boosting_changed",  Callable($Boost, "_on_player_boosting_changed"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	boosting = false
	
	# Rotation
	if Input.is_action_pressed("rotate_left"):
		rotation -= rotation_speed * delta
	if Input.is_action_pressed("rotate_right"):
		rotation += rotation_speed * delta
	
	# Forward movement
	if Input.is_action_pressed("move_forward"):
		var forward = Vector2.UP.rotated(rotation)
		velocity += forward * thrust_accel * delta
		boosting = true
	
	# Apply friction
	if not boosting and velocity.length() > 0:
		var decel = friction * delta
		if decel >= velocity.length():
			velocity = Vector2.ZERO
		else:
			velocity = velocity.normalized() * (velocity.length() - decel)
			
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
	
	position += velocity * delta

	# Fire projectile
	if Input.is_action_pressed("fire") and can_fire:
		can_fire = false
		fire_projectile()
		await get_tree().create_timer(fire_cd).timeout
		can_fire = true
		
	# Boosting visual effect
	$Boost.set_boosting(boosting)
	
	# Handle screen wrapping
	if global_position.y < 0:
		global_position.y = screen_size.y
	elif global_position.y > screen_size.y:
		global_position.y = 0
	if global_position.x < 0:
		global_position.x = screen_size.x
	elif global_position.x > screen_size.x:
		global_position.x = 0
		
func set_boosting_state(value: bool) -> void:
	if boosting != value:
		boosting = value
		emit_signal("boosting_changed", boosting)

func fire_projectile():
	const LASER = preload("res://projectile.tscn")
	var new_laser = LASER.instantiate()
	new_laser.global_position = %FiringPoint.global_position
	new_laser.global_rotation = %FiringPoint.global_rotation
	%FiringPoint.add_child(new_laser)
	

func start(pos):
	position = pos
	rotation = 0
	show()
	$CollisionShape2D.disabled = false

func _on_area_entered(area: Area2D) -> void:
	if area is Meteor:
		var meteor = area
		meteor.queue_free()
		_take_damage()
		
		if current_health <= 0:
			if get_parent().has_method("game_over"):
				get_parent().game_over()
				
	elif area.is_in_group("experience"):
		var xp = area
		xp.queue_free()
		current_xp += 100
		while current_xp >= max_xp:
			current_xp -= max_xp
			current_level += 1
			max_xp += max_xp_increase
			emit_signal("level_up", current_level)
		emit_signal("experience_changed", current_xp, current_level, max_xp)
		
func _take_damage():
	# Update health
	current_health -= 1
	emit_signal("health_changed", current_health)
	
	var original_color = modulate
	modulate = Color(1, 0, 0)
	$CollisionShape2D.call_deferred("set", "disabled", true)
	await get_tree().create_timer(0.3).timeout
	modulate = original_color
	$CollisionShape2D.call_deferred("set", "disabled", false)

# Do effects upon max boost reached
func _on_boost_pulse_complete() -> void:
	$BoostSound.play()
	
	# Tint ship color
	var original_color = modulate
	modulate = Color(1.6, 1.6, 1.6)
	await get_tree().create_timer(0.5).timeout
	modulate = original_color
	
