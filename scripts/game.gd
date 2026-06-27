extends Control

# Game constants
const GRID_COLUMNS = 9
const GRID_ROWS = 5
const CELL_SIZE = Vector2(80, 100)
const GRID_START_POS = Vector2(100, 50)

# Game variables
var sun_count: int = 50
var selected_plant: String = ""
var game_paused: bool = false
var game_over: bool = false
var wave_number: int = 1
var zombies_killed: int = 0

# Plant costs
const PLANT_COSTS = {
	"Sunflower": 50,
	"Peashooter": 100,
	"Wallnut": 50
}

# Plant scenes
var plant_scenes = {
	"Sunflower": preload("res://scenes/plant.tscn"),
	"Peashooter": preload("res://scenes/plant.tscn"),
	"Wallnut": preload("res://scenes/plant.tscn")
}

# Zombie scene
var zombie_scene = preload("res://scenes/zombie.tscn")

# Grid data
var grid_data = []  # 2D array to track plant placement

func _ready():
	# Initialize the game
	print("Game started")
	initialize_grid()
	update_sun_display()
	
	# Add to game group
	add_to_group("game")
	
	# Start sun generation timer
	$SunGenerationTimer.start()
	
	# Start zombie spawning timer
	$ZombieSpawnTimer.start()

func initialize_grid():
	# Initialize grid data
	grid_data = []
	for row in range(GRID_ROWS):
		grid_data.append([])
		for col in range(GRID_COLUMNS):
			grid_data[row].append(null)

func _process(delta):
	# Game loop
	if game_over or game_paused:
		return
	
	# Check for game over conditions
	check_game_over()

func _on_sunflower_slot_pressed():
	select_plant("Sunflower")

func _on_peashooter_slot_pressed():
	select_plant("Peashooter")

func _on_wallnut_slot_pressed():
	select_plant("Wallnut")

func select_plant(plant_name: String):
	# Select a plant for placement
	if sun_count >= PLANT_COSTS.get(plant_name, 0):
		selected_plant = plant_name
		print("Selected plant: ", plant_name)
		# Highlight selected plant slot
		highlight_plant_slot(plant_name)
	else:
		print("Not enough sun for ", plant_name)

func highlight_plant_slot(plant_name: String):
	# Reset all slots
	$PlantSlot/SunflowerSlot.modulate = Color.WHITE
	$PlantSlot/PeashooterSlot.modulate = Color.WHITE
	$PlantSlot/WallnutSlot.modulate = Color.WHITE
	
	# Highlight selected slot
	match plant_name:
		"Sunflower":
			$PlantSlot/SunflowerSlot.modulate = Color.YELLOW
		"Peashooter":
			$PlantSlot/PeashooterSlot.modulate = Color.GREEN
		"Wallnut":
			$PlantSlot/WallnutSlot.modulate = Color.BROWN

func _input(event):
	# Handle mouse input for plant placement
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if selected_plant != "":
			try_place_plant(event.position)

func try_place_plant(mouse_pos: Vector2):
	# Try to place plant at mouse position
	var grid_pos = screen_to_grid(mouse_pos)
	if grid_pos != null:
		var row = grid_pos.y
		var col = grid_pos.x
		if grid_data[row][col] == null:
			place_plant(row, col)
		else:
			print("Cell already occupied")

func screen_to_grid(screen_pos: Vector2) -> Vector2i:
	# Convert screen position to grid coordinates
	var local_pos = screen_pos - GRID_START_POS
	var col = int(local_pos.x / CELL_SIZE.x)
	var row = int(local_pos.y / CELL_SIZE.y)
	
	if col >= 0 and col < GRID_COLUMNS and row >= 0 and row < GRID_ROWS:
		return Vector2i(col, row)
	return null

func place_plant(row: int, col: int):
	# Place the selected plant on the grid
	if selected_plant != "" and sun_count >= PLANT_COSTS.get(selected_plant, 0):
		sun_count -= PLANT_COSTS[selected_plant]
		update_sun_display()
		
		# Create plant instance
		var plant_instance = plant_scenes[selected_plant].instantiate()
		plant_instance.plant_name = selected_plant
		plant_instance.position = grid_to_screen(row, col)
		
		# Add to game board
		$GameBoard.add_child(plant_instance)
		
		# Update grid data
		grid_data[row][col] = plant_instance
		
		# Reset selection
		selected_plant = ""
		highlight_plant_slot("")
		
		print("Placed plant at row ", row, " col ", col)
	else:
		print("Cannot place plant")

func remove_plant_from_grid(plant):
	# Remove plant from grid data
	for row in range(GRID_ROWS):
		for col in range(GRID_COLUMNS):
			if grid_data[row][col] == plant:
				grid_data[row][col] = null
				print("Removed plant from grid at row ", row, " col ", col)
				return

func grid_to_screen(row: int, col: int) -> Vector2:
	# Convert grid coordinates to screen position
	return GRID_START_POS + Vector2(col * CELL_SIZE.x, row * CELL_SIZE.y) + CELL_SIZE / 2

func add_sun(amount: int):
	# Add sun to the counter
	sun_count += amount
	update_sun_display()

func update_sun_display():
	# Update the sun counter display
	$SunCounter.text = "Sun: " + str(sun_count)

func _on_pause_button_pressed():
	# Toggle pause
	game_paused = !game_paused
	get_tree().paused = game_paused
	if game_paused:
		$PauseButton.text = "Resume"
	else:
		$PauseButton.text = "Pause"

func _on_game_timer_timeout():
	# Game timer tick
	pass

func _on_sun_generation_timer_timeout():
	# Generate sun from sky
	generate_sun()

func generate_sun():
	# Create a sun that falls from the sky
	var sun_scene = preload("res://scenes/sun.tscn")
	var sun_instance = sun_scene.instantiate()
	sun_instance.position = Vector2(randf_range(100, 1100), -50)
	add_child(sun_instance)



func _on_zombie_spawn_timer_timeout():
	# Spawn a zombie
	spawn_zombie()

func spawn_zombie():
	# Spawn a zombie at random row on the right side
	var row = randi() % GRID_ROWS
	var zombie_instance = zombie_scene.instantiate()
	zombie_instance.position = Vector2(1300, GRID_START_POS.y + row * CELL_SIZE.y + CELL_SIZE.y / 2)
	zombie_instance.zombie_name = "Zombie " + str(zombies_killed + 1)
	
	# Add to game board
	$GameBoard.add_child(zombie_instance)
	
	# Connect zombie death signal
	zombie_instance.tree_exited.connect(_on_zombie_died)
	
	print("Spawned zombie at row ", row)

func _on_zombie_died():
	# Handle zombie death
	zombies_killed += 1
	print("Zombie died. Total killed: ", zombies_killed)
	
	# Check for wave completion
	if zombies_killed >= wave_number * 5:
		wave_number += 1
		print("Wave ", wave_number, " started!")
		# Increase difficulty
		$ZombieSpawnTimer.wait_time = max(0.5, $ZombieSpawnTimer.wait_time - 0.1)

func check_game_over():
	# Check if any zombie reached the left side
	for zombie in get_tree().get_nodes_in_group("zombies"):
		if zombie.position.x < GRID_START_POS.x:
			game_over = true
			show_game_over()
			break

func show_game_over():
	# Show game over screen
	print("Game Over!")
	# TODO: Implement game over UI
	get_tree().paused = true

func _on_back_button_pressed():
	# Return to main menu
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")