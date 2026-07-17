class_name GameBoard
extends Control

const COLUMNS := 9
const ROWS := 5
const CELL_SIZE := Vector2(80.0, 100.0)

@onready var grid: GridContainer = $Grid

var _plants: Array = []


func _ready() -> void:
	_initialize_cells()


func screen_to_cell(screen_position: Vector2) -> Vector2i:
	var local_position := screen_position - global_position
	var cell := Vector2i(
		floori(local_position.x / CELL_SIZE.x),
		floori(local_position.y / CELL_SIZE.y)
	)
	return cell if is_valid_cell(cell) else Vector2i(-1, -1)


func is_valid_cell(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < COLUMNS and cell.y >= 0 and cell.y < ROWS


func is_cell_empty(cell: Vector2i) -> bool:
	return is_valid_cell(cell) and _plants[cell.y][cell.x] == null


func place_plant(plant: Node2D, cell: Vector2i) -> bool:
	if not is_cell_empty(cell):
		return false
	add_child(plant)
	plant.position = cell_to_position(cell)
	_plants[cell.y][cell.x] = plant
	plant.tree_exiting.connect(_clear_cell.bind(cell, plant), CONNECT_ONE_SHOT)
	return true


func cell_to_position(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * CELL_SIZE.x, cell.y * CELL_SIZE.y) + CELL_SIZE / 2.0


func lane_position(row: int, x_position: float) -> Vector2:
	return Vector2(x_position, row * CELL_SIZE.y + CELL_SIZE.y / 2.0)


func _initialize_cells() -> void:
	_plants.clear()
	for row in ROWS:
		var row_data: Array = []
		row_data.resize(COLUMNS)
		row_data.fill(null)
		_plants.append(row_data)

	for child in grid.get_children():
		child.queue_free()
	for row in ROWS:
		for column in COLUMNS:
			var cell := ColorRect.new()
			cell.custom_minimum_size = CELL_SIZE
			cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
			cell.color = Color(0.6, 0.8, 0.6, 0.5) if (row + column) % 2 == 0 else Color(0.5, 0.7, 0.5, 0.5)
			grid.add_child(cell)


func _clear_cell(cell: Vector2i, plant: Node2D) -> void:
	if is_valid_cell(cell) and _plants[cell.y][cell.x] == plant:
		_plants[cell.y][cell.x] = null
