extends SceneTree

var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	check(load("res://scenes/main_menu.tscn") != null, "main menu scene loads")

	var game_scene: PackedScene = load("res://scenes/game.tscn")
	check(game_scene != null, "game scene loads")
	if game_scene == null:
		finish()
		return

	var game := game_scene.instantiate()
	root.add_child(game)
	await process_frame

	check(game.board != null, "game board initializes")
	check(game.sun_count == 50, "game starts with 50 sun")

	var first_cell_position: Vector2 = game.board.global_position + Vector2(10.0, 10.0)
	game.select_plant("Sunflower")
	game.try_place_plant(first_cell_position)
	check(get_nodes_in_group("plants").size() == 1, "plant can be placed")
	check(game.sun_count == 0, "plant cost is deducted")

	game.add_sun(100)
	game.select_plant("Peashooter")
	game.try_place_plant(first_cell_position)
	check(get_nodes_in_group("plants").size() == 1, "occupied cell rejects another plant")
	check(game.sun_count == 100, "rejected placement does not spend sun")

	var sun_before: int = game.sun_count
	game.generate_sun()
	var suns := game.find_children("*", "Area2D", false, false)
	check(suns.size() == 1, "sky sun is generated")
	if not suns.is_empty():
		suns[0].collect()
		check(game.sun_count == sun_before + 25, "collecting sun updates economy")

	game.spawn_zombie()
	var zombies := get_nodes_in_group("zombies")
	check(zombies.size() == 1, "zombie is spawned")
	if not zombies.is_empty():
		zombies[0].take_damage(100)
		check(game.zombies_killed == 1, "defeated zombie updates wave progress")

	await process_frame
	game.queue_free()
	await process_frame
	finish()


func check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: ", description)
	else:
		failures += 1
		push_error("FAIL: " + description)


func finish() -> void:
	if failures == 0:
		print("All smoke tests passed.")
	else:
		push_error("%d smoke test(s) failed." % failures)
	quit(failures)
