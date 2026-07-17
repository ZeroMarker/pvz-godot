extends CharacterBody2D

signal defeated
signal reached_house

const PLACEHOLDER_TEXTURE := preload("res://assets/icon.svg")
const ATTACK_RANGE := 50.0
const LANE_TOLERANCE := 40.0

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

@onready var sprite: Sprite2D = $Sprite
@onready var health_bar: ProgressBar = $HealthBar

func _ready() -> void:
	sprite.texture = PLACEHOLDER_TEXTURE
	sprite.scale = Vector2(0.2, 0.2)
	sprite.modulate = Color.DARK_SEA_GREEN
	health_bar.max_value = max_health
	health_bar.value = health
	add_to_group("zombies")

func _process(delta: float) -> void:
	# Zombie update logic
	if not is_alive:
		return
	
	# Update attack timer
	attack_timer -= delta
	
	# Check for plants to attack
	check_for_plants()
	
	# Attack if target exists
	if is_instance_valid(target_plant) and attack_timer <= 0:
		attack_plant()
		attack_timer = attack_speed
	
	# Move left if not attacking
	if not is_attacking:
		position.x -= move_speed * delta
		if position.x < 0.0:
			reached_house.emit()
			queue_free()

func check_for_plants() -> void:
	var nearest_plant: Node2D = null
	var nearest_distance := ATTACK_RANGE
	for plant in get_tree().get_nodes_in_group("plants"):
		if not is_instance_valid(plant) or not plant.is_alive:
			continue
		var horizontal_distance: float = absf(position.x - plant.position.x)
		var is_same_lane := absf(position.y - plant.position.y) <= LANE_TOLERANCE
		if is_same_lane and horizontal_distance < nearest_distance:
			nearest_distance = horizontal_distance
			nearest_plant = plant
	target_plant = nearest_plant
	is_attacking = is_instance_valid(target_plant)

func attack_plant() -> void:
	if is_instance_valid(target_plant) and target_plant.has_method("take_damage"):
		target_plant.take_damage(damage)
		if not target_plant.is_alive:
			target_plant = null
			is_attacking = false

func take_damage(amount: int) -> void:
	if not is_alive:
		return
	health -= amount
	health_bar.value = health
	
	if health <= 0:
		die()

func die() -> void:
	if not is_alive:
		return
	is_alive = false
	remove_from_group("zombies")
	defeated.emit()
	queue_free()
