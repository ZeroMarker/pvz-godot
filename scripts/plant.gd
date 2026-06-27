extends CharacterBody2D

# Plant properties
@export var plant_name: String = "Plant"
@export var health: int = 100
@export var max_health: int = 100
@export var attack_damage: int = 0
@export var attack_range: float = 0.0
@export var attack_speed: float = 1.0

# Plant state
var is_alive: bool = true
var target: Node2D = null

func _ready():
	# Initialize plant
	print(plant_name, " planted")
	$HealthBar.max_value = max_health
	$HealthBar.value = health

func _process(delta):
	# Plant update logic
	if not is_alive:
		return
	
	# Check for targets in range
	update_target()
	
	# Attack if target exists
	if target and attack_damage > 0:
		attack()

func update_target():
	# Find nearest zombie in range
	# TODO: Implement target finding logic
	pass

func attack():
	# Attack the target
	if target and target.has_method("take_damage"):
		target.take_damage(attack_damage)

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
	# TODO: Play death animation
	queue_free()

func _on_attack_timer_timeout():
	# Attack timer callback
	attack()