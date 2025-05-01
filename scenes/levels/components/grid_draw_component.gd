class_name GridDraw
extends Node2D

@export var level: Level

var tile_size: int = 0
var rows: int = 0
var cols: int = 0

var window_width: int = 0
var window_height: int = 0

func _ready() -> void:
	window_width = get_window().size.x
	window_height = get_window().size.y

func _draw() -> void:
	var color: Color = Color(255, 255, 255, 0.4)
	
	for i in range(1, rows):
		draw_line(Vector2(0, i * tile_size), Vector2(window_width, i * tile_size), 
			color, 1)
	
	for i in range(1, cols):
		draw_line(Vector2(i * tile_size, 0), Vector2(i * tile_size, window_height), 
			color, 1)
