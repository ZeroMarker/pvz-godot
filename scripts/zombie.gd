extends CharacterBody2D

# Zombie properties
@export var zombie_name: String = "Zombie"
@export var health: int = 100
@export var max_health: int = 100
@export var damage: int = 20
@export var move_speed: float = 50.0
@export var attack_speed: float = 1.0

# Zombie state
var is_alive: bool = true
var is_attacking: bool = false
var target_plant: Node2D = null
var attack_timer: float = 0.0

func _ready():
	# Initialize zombie
	print(zombie_name, " spawned")
	$HealthBar.max_value = max_health
	$HealthBar.value = health
	
	# Add to zombies group
	add_to_group("zombies")

func _process(delta):
	# Zombie update logic
	if not is_alive:
		return
	
	# Update attack timer
	attack_timer -= delta
	
	# Check for plants to attack
	check_for_plants()
	
	# Attack if target exists
	if target_plant and attack_timer <= 0:
		attack_plant()
		attack_timer = attack_speed
	
	# Move left if not attacking
	if not is_attacking:
		position.x -= move_speed * delta

func check_for_plants():
	# Check if there's a plant to attack
	var plants = get_tree().get_nodes_in_group("plants")
	var nearest_plant = null
	var nearest_distance = 50.0  # Attack range
	
	for plant in plants:
		if plant.is_alive:
			var distance = position.distance_to(plant.position)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest_plant = plant
	
	if nearest_plant != target_plant:
		target_plant = nearest_plant
		is_attacking = target_plant != null

func attack_plant():
	# Attack the target plant
	if target_plant and target_plant.has_method("take_damage"):
		target_plant.take_damage(damage)
		print(zombie_name, " attacked ", target_plant.plant_name)
		
		# Check if plant is dead
		if not target_plant.is_alive:
			target_plant = null
			is_attacking = false

func take_damage(amount: int):
	# Take damage
	health -= amount
	$HealthBar.value = health
	
	if health <= 0:
		die()

func die():
	# Zombie death
	is_alive = false
	print(zombie_name, " died")
	
	# Remove from zombies group
	remove_from_group("zombies")
	
	# TODO: Play death animation
	queue_free()

func _on_movement_timer_timeout():
	# Movement timer callback
	# This can be used for smoother movement updates
	pass