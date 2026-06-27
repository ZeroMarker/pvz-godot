extends CharacterBody2D

# Plant properties
@export var plant_name: String = "Plant"
@export var health: int = 100
@export var max_health: int = 100
@export var attack_damage: int = 0
@export var attack_range: float = 800.0  # Full width for pea shooting
@export var attack_speed: float = 1.5
@export var sun_generation_rate: float = 0.0  # For sunflowers

# Plant state
var is_alive: bool = true
var target: Node2D = null
var attack_timer: float = 0.0
var sun_timer: float = 0.0

func _ready():
	# Initialize plant
	print(plant_name, " planted")
	$HealthBar.max_value = max_health
	$HealthBar.value = health
	
	# Set plant-specific properties
	match plant_name:
		"Sunflower":
			health = 100
			max_health = 100
			attack_damage = 0
			sun_generation_rate = 24.0  # Generate sun every 24 seconds
		"Peashooter":
			health = 100
			max_health = 100
			attack_damage = 20
			attack_range = 800.0
		"Wallnut":
			health = 400
			max_health = 400
			attack_damage = 0
	
	# Update health bar
	$HealthBar.max_value = max_health
	$HealthBar.value = health
	
	# Start attack timer if plant can attack
	if attack_damage > 0:
		$AttackTimer.wait_time = attack_speed
		$AttackTimer.start()

func _process(delta):
	# Plant update logic
	if not is_alive:
		return
	
	# Update attack timer
	attack_timer -= delta
	
	# Check for targets in range
	update_target()
	
	# Attack if target exists and timer is ready
	if target and attack_damage > 0 and attack_timer <= 0:
		attack()
		attack_timer = attack_speed
	
	# Sun generation for sunflowers
	if sun_generation_rate > 0:
		sun_timer -= delta
		if sun_timer <= 0:
			generate_sun()
			sun_timer = sun_generation_rate

func update_target():
	# Find nearest zombie in range
	var zombies = get_tree().get_nodes_in_group("zombies")
	var nearest_zombie = null
	var nearest_distance = attack_range
	
	for zombie in zombies:
		if zombie.is_alive:
			var distance = position.distance_to(zombie.position)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest_zombie = zombie
	
	target = nearest_zombie

func attack():
	# Attack the target
	if target and target.has_method("take_damage"):
		target.take_damage(attack_damage)
		print(plant_name, " attacked ", target.zombie_name)
		
		# Create pea projectile for peashooter
		if plant_name == "Peashooter":
			create_pea()

func create_pea():
	# Create a pea projectile
	var pea = Sprite2D.new()
	pea.texture = load("res://assets/icon.svg")  # Using icon as pea for now
	pea.position = position + Vector2(40, 0)
	pea.scale = Vector2(0.1, 0.1)
	get_parent().add_child(pea)
	
	# Animate pea movement
	var tween = create_tween()
	tween.tween_property(pea, "position:x", 1300, 1.0)
	tween.tween_callback(pea.queue_free)

func generate_sun():
	# Generate sun for sunflowers
	if plant_name == "Sunflower":
		var sun_scene = preload("res://scenes/sun.tscn")
		var sun_instance = sun_scene.instantiate()
		sun_instance.position = position + Vector2(0, -50)
		get_parent().add_child(sun_instance)



func take_damage(amount: int):
	# Take damage
	health -= amount
	$HealthBar.value = health
	
	if health <= 0:
		die()

func die():
	# Plant death
	is_alive = false
	print(plant_name, " died")
	
	# Remove from grid
	var game = get_tree().get_first_node_in_group("game")
	if game:
		game.remove_plant_from_grid(self)
	
	# TODO: Play death animation
	queue_free()

func _on_attack_timer_timeout():
	# Attack timer callback
	attack()