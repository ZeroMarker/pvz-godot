extends Area2D

signal collected(value: int)

@export var sun_value := 25
@export var fall_speed := 100.0

var is_collected := false

@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	sprite.texture = load("res://assets/icon.svg")
	sprite.scale = Vector2(0.3, 0.3)
	input_event.connect(_on_input_event)

func _process(delta: float) -> void:
	if not is_collected:
		position.y += fall_speed * delta
		if position.y > 800:
			queue_free()

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and not is_collected:
		collect()

func collect() -> void:
	is_collected = true
	input_pickable = false
	collected.emit(sun_value)
	var tween := create_tween()
	tween.set_parallel()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2)
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	await tween.finished
	queue_free()
