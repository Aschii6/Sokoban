extends Node2D

signal move_player_to(grid_pos: Vector2i)

const BRICK = preload("res://scenes/blocks/brick/brick.tscn")
const WOOD_CRATE = preload("res://scenes/blocks/wood_crate/wood_crate.tscn")

const STONE_FLOOR = preload("res://scenes/floors/stone_floor/stone_floor.tscn")

var floor_scene: PackedScene

@onready var player: Player = $Player
@onready var grid_draw: GridDraw = $GridDraw

var block_list: Array[Block] = []

var tile_size: int = 128
var rows: int = 1
var cols: int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_level()
	player.request_move.connect(on_player_request_move)

func on_player_request_move(direction: Vector2i):
	var player_pos: Vector2i = player.grid_pos
	var new_pos: Vector2i = player_pos + direction
	
	move_player_to.emit(new_pos)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func load_level():
	var file = FileAccess.open("res://scenes/levels/proto/config.json", FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	
	rows = data["rows"]
	cols = data["cols"]
	tile_size = data["tile_size"]
	
	var floor_type: String = data["floor_type"]
	
	match floor_type:
		"stone_floor":
			floor_scene = STONE_FLOOR
	
	for i in range(rows):
		for j in range(cols):
			var floor: Floor = floor_scene.instantiate()
			floor.position = Vector2(j + 1/2, i + 1/2) * tile_size
			add_child(floor)
	
	for block in data["blocks"]:
		var type: String = block["type"]
		if type == "brick":
			var brick: Block = BRICK.instantiate()
			brick.grid_pos = Vector2i(block["x"], block["y"])
			brick.position = (Vector2(brick.grid_pos) + Vector2.ONE * 1/2) * tile_size
			block_list.push_back(brick)
			add_child(brick)
	
	init_player(data)

func init_player(data):
	player.rows = rows
	player.cols = cols
	player.tile_size = tile_size
	var player_pos: Array = data["player_grid_pos"]
	player.initial_grid_pos = Vector2i(player_pos[0], player_pos[1])
