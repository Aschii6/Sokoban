class_name GridDraw
extends Node2D

@export var level: Level

var TILE_SIZE: int = 0
var rows: int = 0
var cols: int = 0

var window_width: int = 0
var window_height: int = 0

func _ready() -> void:
	if (level is Level):
		TILE_SIZE = level.TILE_SIZE
		rows = level.rows
		cols = level.cols
	
	window_width = get_window().size.x
	window_height = get_window().size.y

func _draw() -> void:
	for i in range(1, rows):
		draw_line(Vector2(0, i * TILE_SIZE), Vector2(window_width, i * TILE_SIZE), 
			Color.WHITE, 1)
	
	for i in range(1, cols):
		draw_line(Vector2(i * TILE_SIZE, 0), Vector2(i * TILE_SIZE, window_height), 
		Color.WHITE, 1)
