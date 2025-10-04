extends Node

@export var meteor_scene: PackedScene
var time
var meteor_split_count = 2
var xp_spawn_count = 5
var xp_value = 20

# Called when the node enters the scene tree for the first time.
func _ready():
	$Player.connect("health_changed", Callable($HUD, "update_health"))
	$Player.connect("experience_changed", Callable($HUD, "update_experience"))
	$Player.level_up.connect(_on_player_level_up)
	$HUD.init_experience($Player.current_level, $Player.max_xp)

func game_over():
	$GameClockTimer.stop()
	$MeteorTimer.stop()
	$HUD.show_game_over()
	$Player.hide()
	get_tree().call_group("meteors", "queue_free")
	get_tree().call_group("experience", "queue_free")
	$MainMusic.stop()
	$GameOverSound.play()
	
func new_game():
	time = 0
	$Player.show()
	$Player.start($StartPosition.position)
	$Player.current_health = $Player.DEFAULT_HEALTH
	$Player.current_level = 1
	$Player.current_xp = 0
	$Player.max_xp = 100
	$Player.max_speed = $Player.DEFAULT_MAX_SPEED
	$Player.fire_cd = $Player.DEFAULT_FIRE_CD
	$StartTimer.start()
	$HUD.update_health($Player.current_health)
	$HUD.init_experience($Player.current_level, $Player.max_xp)
	$HUD.update_experience($Player.current_xp, $Player.current_level, $Player.max_xp)
	$HUD.update_timer(time)
	$HUD.show_message("GO!")
	get_tree().call_group("meteors", "queue_free")
	# Immediately spawn 1 meteor
	_on_meteor_timer_timeout()

func _on_meteor_timer_timeout() -> void:
	# Create a new instance of the Meteor scene.
	var meteor := meteor_scene.instantiate()  

	# Choose a random location on Path2D.
	var meteor_spawn_location := $MeteorPath/MeteorSpawnLocation
	meteor_spawn_location.progress_ratio = randf()

	# Set the meteor's position to the random location.
	meteor.global_position = meteor_spawn_location.global_position
	
	meteor.connect("destroyed", Callable(self, "_on_meteor_destroyed"))
	meteor.add_to_group("meteors")

	# Spawn the meteor by adding it to the Main scene.
	add_child(meteor)
	
func _on_game_clock_timer_timeout() -> void:
	time += 1
	$HUD.update_timer(time)

func _on_start_timer_timeout():
	$MeteorTimer.start()
	$GameClockTimer.start()
	$MainMusic.play()

func _on_meteor_destroyed(meteor) -> void:
	match meteor.size:
		Meteor.MeteorSize.LARGE:
			_split_meteors(meteor, Meteor.MeteorSize.MEDIUM)
		Meteor.MeteorSize.MEDIUM:
			_split_meteors(meteor, Meteor.MeteorSize.SMALL)
		Meteor.MeteorSize.SMALL:
			_drop_experience(meteor.global_position)

func _split_meteors(parent: Meteor, new_size: int) -> void:
	for i in range(meteor_split_count):
		var child: Meteor = meteor_scene.instantiate()
		child.size = new_size
		# Spawn children where parent was destroyed
		child.global_position = parent.global_position
		child.connect("destroyed", Callable(self, "_on_meteor_destroyed"))
		child.add_to_group("meteors")
		call_deferred("add_child", child)
		
func _drop_experience(pos: Vector2) -> void:
	call_deferred("_spawn_boids_deferred", pos)
		
func _spawn_boids_deferred(pos: Vector2) -> void:
	var player = $Player
	var flock = $Flock
	if flock == null:
		push_error("Flock node not found")
		return

	for i in range(xp_spawn_count):
		var boid = flock.SpawnBoidAtPosition(pos, player)
		if boid != null:
			if not boid.Collected.is_connected(Callable(self, "_on_boid_collected")):
				boid.Collected.connect(Callable(self, "_on_boid_collected"))

# Handle adding experience to player
func _on_boid_collected():
	$Player.add_experience(xp_value)
	
func _on_player_level_up(level: int):
	$HUD.show_upgrade_menu()
	
func _on_hud_upgrade_selected(choice: int) -> void:
	match choice:
		1:
			# Decrease fire cooldown, limit of 0.1
			$Player.fire_cd = max($Player.fire_cd * 0.75, 0.1)
		2:
			# Limit max health (until better health system implemented)
			if $Player.current_health < 5:
				$Player.current_health += 1
				$HUD.update_health($Player.current_health)
		3:
			# No speed limit, who cares
			$Player.max_speed += 50
