class_name Level
extends Node2D

signal move_player_to(grid_pos: Vector2i)

const WIN_SCREEN = preload("res://scenes/win_screen/win_screen.tscn")

const BRICK = preload("res://scenes/blocks/brick/brick.tscn")
const WOOD_CRATE = preload("res://scenes/blocks/wood_crate/wood_crate.tscn")

const STONE_FLOOR = preload("res://scenes/floors/stone_floor/stone_floor.tscn")
const MARKED_STONE_FLOOR = preload("res://scenes/floors/marked_floors/marked_stone_floor/marked_stone_floor.tscn")

@export var config_file: Resource

@export var player: Player
@export var grid_draw: GridDraw

var tile_size: int = 128
var rows: int = 6
var cols: int = 10

var block_list: Array[Block] = []
var marked_floor_list: Array[MarkedFloor] = []
var excluded_floor_list: Array[Vector2i] = [] # Not an ideal solution

var floor_scene: PackedScene
var marked_floor_scene: PackedScene

func _ready() -> void:
	load_data()
	player.request_move.connect(on_player_request_move)

func load_data() -> void:
	var file = FileAccess.open(config_file.resource_path, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	rows = data["rows"]
	cols = data["cols"]
	tile_size = data["tile_size"]
	
	var floor_type: String = data["floor_type"]
	
	match floor_type:
		"stone_floor":
			floor_scene = STONE_FLOOR
			marked_floor_scene = MARKED_STONE_FLOOR
	
	for m_floor in data["marked_floors"]:
		var marked_floor: MarkedFloor = marked_floor_scene.instantiate()
		marked_floor.grid_pos = Vector2i(m_floor["x"], m_floor["y"])
		marked_floor.position = (Vector2(marked_floor.grid_pos) + Vector2.ONE * 1/2) * tile_size
		marked_floor_list.push_back(marked_floor)
		add_child(marked_floor)
		
		excluded_floor_list.push_back(marked_floor.grid_pos)
	
	for i in range(rows):
		for j in range(cols):
			if Vector2i(j, i) in excluded_floor_list:
				continue
			var floor: Floor = floor_scene.instantiate()
			floor.position = (Vector2(j, i) + Vector2.ONE * 1/2) * tile_size
			add_child(floor)
	
	for block in data["blocks"]:
		var type: String = block["type"]
		if type == "brick":
			var brick: Brick = BRICK.instantiate()
			brick.grid_pos = Vector2i(block["x"], block["y"])
			brick.position = (Vector2(brick.grid_pos) + Vector2.ONE * 1/2) * tile_size
			block_list.push_back(brick)
			add_child(brick)
		elif type == "wood_crate":
			var wood_crate: WoodCrate = WOOD_CRATE.instantiate()
			wood_crate.grid_pos = Vector2i(block["x"], block["y"])
			wood_crate.position = (Vector2(wood_crate.grid_pos) + Vector2.ONE * 1/2) * tile_size
			block_list.push_back(wood_crate)
			add_child(wood_crate)
	
	init_player(data)
	init_grid_draw()

func init_player(data):
	player.rows = rows
	player.cols = cols
	player.tile_size = tile_size
	var player_pos: Array = data["player_grid_pos"]
	player.initial_grid_pos = Vector2i(player_pos[0], player_pos[1])

func init_grid_draw():
	grid_draw.rows = rows
	grid_draw.cols = cols
	grid_draw.tile_size = tile_size

func _process(delta: float) -> void:
	if (check_win()):
		get_tree().change_scene_to_packed(WIN_SCREEN)

func on_player_request_move(direction: Vector2i):
	var grid_pos: Vector2i = player.grid_pos
	
	if (is_next_player_move_oob(grid_pos, direction)):
		return
	
	if (!can_move(grid_pos, direction)):
		return
	
	if (!try_move_crates(grid_pos, direction)):
		return
	
	var new_pos: Vector2i = grid_pos + direction
	move_player_to.emit(new_pos)

# oob = Out of Bounds
func is_next_player_move_oob(grid_pos: Vector2i, direction: Vector2i):
	match (direction):
		Vector2i.UP:
			if grid_pos.y == 0:
				return true
		Vector2i.LEFT:
			if grid_pos.x == 0:
				return true
		Vector2i.DOWN:
			if grid_pos.y >= rows - 1:
				return true
		Vector2i.RIGHT:
			if grid_pos.x >= cols - 1:
				return true
	return false

# Check collision with bricks
func can_move(grid_pos, direction):
	var new_pos: Vector2i = grid_pos + direction
	for block in block_list:
		if block is Brick:
			if new_pos == block.grid_pos:
				return false
	
	return true

# Returns true if player can move after, false otherwise
func try_move_crates(grid_pos: Vector2i, direction:Vector2i):
	var new_pos: Vector2i = grid_pos + direction
	for block in block_list:
		if new_pos == block.grid_pos:
			if block is WoodCrate:
				if (!try_move_crates(new_pos, direction)):
					return false
				else:
					block.grid_pos = new_pos + direction
					var target_position: Vector2 = (Vector2(block.grid_pos) + Vector2.ONE * 1/2) * tile_size
					
					var tween: Tween = create_tween()
					# Tween durations should be less or equal than player move tween duration
					tween.tween_property(block, "position", target_position, 0.4).set_ease(Tween.EASE_IN_OUT)
					
					return true
			elif block is Brick:
				return false
	
	return true

func check_win():
	var marked_floors_covered: int = 0
	var marked_floors_count: int = marked_floor_list.size()
	
	for marked_floor: MarkedFloor in marked_floor_list:
		for block in block_list:
			if block is WoodCrate and block.grid_pos == marked_floor.grid_pos:
				marked_floors_covered += 1
	
	if marked_floors_covered == marked_floors_count:
		return true
	else:
		return false
