class_name Player
extends Area2D

@export var rows: int = 1
@export var cols: int = 1

@export var initial_pos: Vector2i = Vector2i.ZERO

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const TILE_SIZE: float = 128

var grid_pos: Vector2i
var input_queue: Array[Vector2i] = []
var tween_playing: bool = false

func _ready():
	grid_pos = initial_pos
	position = (Vector2(grid_pos) + Vector2.ONE * 1/2) * TILE_SIZE

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("up"):
		try_push_to_input_queue(Vector2i.UP)
	elif Input.is_action_just_pressed("left"):
		try_push_to_input_queue(Vector2i.LEFT)
	elif Input.is_action_just_pressed("down"):
		try_push_to_input_queue(Vector2i.DOWN)
	elif Input.is_action_just_pressed("right"):
		try_push_to_input_queue(Vector2i.RIGHT)
	
	if (!input_queue.is_empty()):
		move()

func move() -> void:
	if tween_playing:
		return
	
	var direction: Vector2i = input_queue.pop_front()
	
	if (is_next_move_oob(direction)):
		return
	
	grid_pos += direction
	var target_position: Vector2 = (Vector2(grid_pos) + Vector2.ONE * 1/2) * TILE_SIZE
	
	tween_playing = true
	var tween: Tween = create_tween()
	tween.tween_property(self, "position", target_position, 0.6).set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(_on_tweet_finished)
	
	change_animation(direction)

func _on_tweet_finished():
	tween_playing = false
	animated_sprite_2d.stop()

func change_animation(direction: Vector2i):
	match (direction):
		Vector2i.UP:
			animated_sprite_2d.play("walk_up")
		Vector2i.LEFT:
			animated_sprite_2d.play("walk_left")
		Vector2i.DOWN:
			animated_sprite_2d.play("walk_down")
		Vector2i.RIGHT:
			animated_sprite_2d.play("walk_right")

func try_push_to_input_queue(direction: Vector2i):
	if input_queue.size() >= 1:
		return
	
	input_queue.push_back(direction)

# oob = Out of Bounds
func is_next_move_oob(direction: Vector2i):
	match (direction):
		Vector2i.UP:
			if grid_pos.y == 0:
				return true
		Vector2i.LEFT:
			if grid_pos.x == 0:
				return true
		Vector2i.DOWN:
			if grid_pos.y >= cols - 1:
				return true
		Vector2i.RIGHT:
			if grid_pos.x >= rows - 1:
				return true
	return false
