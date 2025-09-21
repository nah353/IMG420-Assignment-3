class_name Meteor
extends Area2D

signal destroyed()

var movement_vector := Vector2(0, -1)

enum MeteorSize{LARGE, MEDIUM, SMALL}
@export var size := MeteorSize.LARGE

const base_speed := 40
const random_speed_range := 20
var speed := 0

@onready var sprite = $Sprite2D
@onready var hitbox = $CollisionShape2D

func _ready():
	rotation = randf_range(0, 2*PI)
	
	match size:
		MeteorSize.LARGE:
			speed = randf_range(base_speed, base_speed + random_speed_range)
			sprite.texture = preload("res://space_game_2d_assets/meteor_squareDetailedLarge.png")
			sprite.scale *= 1.5
			hitbox.scale *= 1.55
			
		MeteorSize.MEDIUM:
			speed = randf_range(base_speed * 2, (base_speed + random_speed_range) * 2)
			sprite.texture = preload("res://space_game_2d_assets/meteor_detailedLarge.png")
			
		MeteorSize.SMALL:
			speed = randf_range(base_speed * 3, (base_speed + random_speed_range) * 3)
			sprite.texture = preload("res://space_game_2d_assets/meteor_detailedSmall.png")
			hitbox.scale *= 0.70

func _process(delta: float) -> void:
	global_position += movement_vector.rotated(rotation) * speed * delta
	
	# Handle screen wrapping
	var radius = hitbox.shape.radius
	
	var screen_size = get_viewport_rect().size
	if (global_position.y + radius) < 0:
		global_position.y = (screen_size.y + radius)
	elif (global_position.y - radius) > screen_size.y:
		global_position.y = -radius
	if (global_position.x + radius) < 0:
		global_position.x = (screen_size.x + radius)
	elif (global_position.x - radius) > screen_size.x:
		global_position.x = -radius

func destroy():
	emit_signal("destroyed", self)
	queue_free()
