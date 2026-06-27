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

func _ready():
	# Initialize zombie
	print(zombie_name, " spawned")
	$HealthBar.max_value = max_health
	$HealthBar.value = health

func _process(delta):
	# Zombie update logic
	if not is_alive:
		return
	
	# Move left if not attacking
	if not is_attacking:
		position.x -= move_speed * delta
	
	# Check for plants to attack
	check_for_plants()

func check_for_plants():
	# Check if there's a plant to attack
	# TODO: Implement plant detection logic
	pass

func attack_plant():
	# Attack the target plant
	if target_plant and target_plant.has_method("take_damage"):
		target_plant.take_damage(damage)
		print(zombie_name, " attacked ", target_plant.plant_name)

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
	# TODO: Play death animation
	queue_free()

func _on_movement_timer_timeout():
	# Movement timer callback
	# This can be used for smoother movement updates
	pass