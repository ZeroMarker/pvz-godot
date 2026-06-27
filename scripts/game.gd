extends Control

# Game variables
var sun_count: int = 50
var selected_plant: String = ""
var game_paused: bool = false

# Plant costs
const PLANT_COSTS = {
	"Sunflower": 50,
	"Peashooter": 100,
	"Wallnut": 50
}

func _ready():
	# Initialize the game
	print("Game started")
	update_sun_display()

func _process(delta):
	# Game loop
	pass

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
	else:
		print("Not enough sun for ", plant_name)

func place_plant(grid_position: Vector2):
	# Place the selected plant on the grid
	if selected_plant != "" and sun_count >= PLANT_COSTS.get(selected_plant, 0):
		sun_count -= PLANT_COSTS[selected_plant]
		update_sun_display()
		# TODO: Create plant instance at grid_position
		print("Placed ", selected_plant, " at ", grid_position)
		selected_plant = ""
	else:
		print("Cannot place plant")

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
	# TODO: Spawn zombies, generate sun, etc.
	pass