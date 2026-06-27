extends Control

# Main menu script

func _ready():
	# Set up the main menu
	print("Main menu loaded")

func _on_start_button_pressed():
	# Start the game
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_settings_button_pressed():
	# Open settings menu
	print("Settings menu opened")

func _on_quit_button_pressed():
	# Quit the game
	get_tree().quit()