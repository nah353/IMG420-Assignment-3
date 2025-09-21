extends Area2D

signal collected

func _ready():
	connect("area_entered", Callable(self, "_on_area_entered"))

func _on_area_entered(area: Area2D) -> void:
	if area is Player:  # check if it's the player
		emit_signal("collected")
		queue_free()
