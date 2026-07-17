extends Control

const PLANT_SCENE := preload("res://scenes/plant.tscn")
const ZOMBIE_SCENE := preload("res://scenes/zombie.tscn")
const SUN_SCENE := preload("res://scenes/sun.tscn")
const PLANT_COSTS := {
	"Sunflower": 50,
	"Peashooter": 100,
	"Wallnut": 50,
}

@onready var board: GameBoard = $GameBoard
@onready var sun_counter: Label = $SunCounter
@onready var pause_button: Button = $PauseButton
@onready var zombie_spawn_timer: Timer = $ZombieSpawnTimer
@onready var plant_buttons := {
	"Sunflower": $PlantSlot/SunflowerSlot,
	"Peashooter": $PlantSlot/PeashooterSlot,
	"Wallnut": $PlantSlot/WallnutSlot,
}

var sun_count := 50
var selected_plant := ""
var wave_number := 1
var zombies_killed := 0
var game_over := false


func _ready() -> void:
	add_to_group("game")
	update_sun_display()


func _input(event: InputEvent) -> void:
	if game_over:
		return
	if event.is_action_pressed("ui_cancel"):
		set_paused(not get_tree().paused)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		try_place_plant(event.position)


func select_plant(plant_name: String) -> void:
	if not PLANT_COSTS.has(plant_name) or sun_count < PLANT_COSTS[plant_name]:
		return
	selected_plant = plant_name
	for name in plant_buttons:
		plant_buttons[name].modulate = Color.YELLOW if name == plant_name else Color.WHITE


func try_place_plant(screen_position: Vector2) -> void:
	if selected_plant.is_empty():
		return
	var cell := board.screen_to_cell(screen_position)
	if not board.is_cell_empty(cell):
		return
	var plant = PLANT_SCENE.instantiate()
	plant.plant_name = selected_plant
	plant.sun_created.connect(_on_plant_sun_created)
	if board.place_plant(plant, cell):
		sun_count -= PLANT_COSTS[selected_plant]
		selected_plant = ""
		for button in plant_buttons.values():
			button.modulate = Color.WHITE
		update_sun_display()


func add_sun(amount: int) -> void:
	sun_count += amount
	update_sun_display()


func update_sun_display() -> void:
	sun_counter.text = "Sun: %d" % sun_count
	for name in plant_buttons:
		plant_buttons[name].disabled = sun_count < PLANT_COSTS[name]


func generate_sun() -> void:
	var sun = SUN_SCENE.instantiate()
	sun.position = Vector2(randf_range(board.global_position.x, board.global_position.x + board.size.x), -50.0)
	sun.collected.connect(add_sun)
	add_child(sun)


func _on_plant_sun_created(sun: Area2D, spawn_position: Vector2) -> void:
	sun.position = spawn_position
	sun.collected.connect(add_sun)
	add_child(sun)


func spawn_zombie() -> void:
	var zombie = ZOMBIE_SCENE.instantiate()
	var row := randi_range(0, GameBoard.ROWS - 1)
	zombie.position = board.lane_position(row, GameBoard.COLUMNS * GameBoard.CELL_SIZE.x + 100.0)
	zombie.zombie_name = "Zombie %d" % (zombies_killed + 1)
	zombie.defeated.connect(_on_zombie_defeated)
	zombie.reached_house.connect(_on_zombie_reached_house)
	board.add_child(zombie)


func set_paused(paused: bool) -> void:
	get_tree().paused = paused
	pause_button.text = "Resume" if paused else "Pause"


func show_game_over() -> void:
	if game_over:
		return
	game_over = true
	set_paused(true)
	pause_button.text = "Game Over"
	pause_button.disabled = true


func _on_zombie_defeated() -> void:
	zombies_killed += 1
	if zombies_killed >= wave_number * 5:
		wave_number += 1
		zombie_spawn_timer.wait_time = maxf(0.5, zombie_spawn_timer.wait_time - 0.1)


func _on_zombie_reached_house() -> void:
	show_game_over()


func _on_sunflower_slot_pressed() -> void:
	select_plant("Sunflower")


func _on_peashooter_slot_pressed() -> void:
	select_plant("Peashooter")


func _on_wallnut_slot_pressed() -> void:
	select_plant("Wallnut")


func _on_pause_button_pressed() -> void:
	set_paused(not get_tree().paused)


func _on_sun_generation_timer_timeout() -> void:
	generate_sun()


func _on_zombie_spawn_timer_timeout() -> void:
	spawn_zombie()


func _on_back_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
