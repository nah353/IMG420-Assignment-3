extends Area2D

@export var speed := 1000.0

func _process(delta):
	var direction = Vector2.UP.rotated(rotation)
	position += direction * speed * delta
	
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area is Meteor:
		var meteor = area
		meteor.destroy()
		queue_free()
