extends Area2D

# Sun properties
var sun_value: int = 25
var fall_speed: float = 100.0
var collected: bool = false

func _ready():
	# Initialize sun
	$Sprite.texture = load("res://assets/icon.svg")  # Using icon as sun for now
	$Sprite.scale = Vector2(0.3, 0.3)
	
	# Connect input event
	input_event.connect(_on_input_event)

func _process(delta):
	# Sun falling logic
	if not collected:
		position.y += fall_speed * delta
		
		# Remove if off screen
		if position.y > 800:
			queue_free()

func _on_input_event(_viewport, event, _shape_idx):
	# Handle click on sun
	if event is InputEventMouseButton and event.pressed and not collected:
		collect()

func collect():
	# Collect the sun
	collected = true
	
	# Add sun to game
	var game = get_tree().get_first_node_in_group("game")
	if game:
		game.add_sun(sun_value)
	
	# Play collection animation
	$AnimationPlayer.play("collect")
	
	# Remove after animation
	await $AnimationPlayer.animation_finished
	queue_free()

func set_sun_value(value: int):
	# Set sun value
	sun_value = value

func set_fall_speed(speed: float):
	# Set fall speed
	fall_speed = speed