extends CharacterBody2D

signal sun_created(sun: Area2D, spawn_position: Vector2)

const SUN_SCENE := preload("res://scenes/sun.tscn")
const PLACEHOLDER_TEXTURE := preload("res://assets/icon.svg")
const LANE_TOLERANCE := 40.0

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

@onready var sprite: Sprite2D = $Sprite
@onready var health_bar: ProgressBar = $HealthBar

func _ready() -> void:
	# Initialize plant
	print(plant_name, " planted")
	sprite.texture = PLACEHOLDER_TEXTURE
	sprite.scale = Vector2(0.2, 0.2)
	add_to_group("plants")
	
	# Set plant-specific properties
	match plant_name:
		"Sunflower":
			sprite.modulate = Color.GOLD
			health = 100
			max_health = 100
			attack_damage = 0
			sun_generation_rate = 24.0  # Generate sun every 24 seconds
		"Peashooter":
			sprite.modulate = Color.LIME_GREEN
			health = 100
			max_health = 100
			attack_damage = 20
			attack_range = 800.0
		"Wallnut":
			sprite.modulate = Color.SADDLE_BROWN
			health = 400
			max_health = 400
			attack_damage = 0
	
	# Update health bar
	health_bar.max_value = max_health
	health_bar.value = health
	
func _process(delta: float) -> void:
	# Plant update logic
	if not is_alive:
		return
	
	# Update attack timer
	attack_timer -= delta
	
	# Check for targets in range
	update_target()
	
	# Attack if target exists and timer is ready
	if is_instance_valid(target) and attack_damage > 0 and attack_timer <= 0:
		attack()
		attack_timer = attack_speed
	
	# Sun generation for sunflowers
	if sun_generation_rate > 0:
		sun_timer -= delta
		if sun_timer <= 0:
			generate_sun()
			sun_timer = sun_generation_rate

func update_target() -> void:
	var nearest_zombie: Node2D = null
	var nearest_distance := attack_range
	for zombie in get_tree().get_nodes_in_group("zombies"):
		if not is_instance_valid(zombie) or not zombie.is_alive:
			continue
		var horizontal_distance: float = zombie.position.x - position.x
		var is_same_lane := absf(zombie.position.y - position.y) <= LANE_TOLERANCE
		if is_same_lane and horizontal_distance >= 0.0 and horizontal_distance < nearest_distance:
			nearest_distance = horizontal_distance
			nearest_zombie = zombie
	target = nearest_zombie

func attack() -> void:
	if is_instance_valid(target) and target.has_method("take_damage"):
		target.take_damage(attack_damage)
		if plant_name == "Peashooter":
			create_pea()

func create_pea() -> void:
	var pea := Sprite2D.new()
	pea.texture = PLACEHOLDER_TEXTURE
	pea.position = position + Vector2(40, 0)
	pea.scale = Vector2(0.1, 0.1)
	get_parent().add_child(pea)
	
	# Animate pea movement
	var tween := create_tween()
	tween.tween_property(pea, "position:x", 1300, 1.0)
	tween.tween_callback(pea.queue_free)

func generate_sun() -> void:
	if plant_name == "Sunflower":
		var sun = SUN_SCENE.instantiate()
		sun_created.emit(sun, global_position + Vector2(0, -50))



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
	queue_free()
