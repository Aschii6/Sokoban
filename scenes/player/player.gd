extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const TILE_SIZE: float = 128

var input_queue: Array[Vector2] = []
var tween_playing: bool = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("up"):
		try_push_to_input_queue(Vector2.UP)
	elif Input.is_action_just_pressed("left"):
		try_push_to_input_queue(Vector2.LEFT)
	elif Input.is_action_just_pressed("down"):
		try_push_to_input_queue(Vector2.DOWN)
	elif Input.is_action_just_pressed("right"):
		try_push_to_input_queue(Vector2.RIGHT)
	
	if (!input_queue.is_empty()):
		move()

func move() -> void:
	if tween_playing:
		return
	
	var direction: Vector2 = input_queue.pop_front()
	var target_position: Vector2 = position + direction * TILE_SIZE
	
	tween_playing = true
	var tween: Tween = create_tween()
	tween.tween_property(self, "position", target_position, 0.6).set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(_on_tweet_finished)
	
	change_animation(direction)

func _on_tweet_finished():
	tween_playing = false
	animated_sprite_2d.stop()

func change_animation(direction: Vector2):
	match (direction):
		Vector2.UP:
			animated_sprite_2d.play("walk_up")
		Vector2.LEFT:
			animated_sprite_2d.play("walk_left")
		Vector2.DOWN:
			animated_sprite_2d.play("walk_down")
		Vector2.RIGHT:
			animated_sprite_2d.play("walk_right")

func try_push_to_input_queue(direction: Vector2):
	if input_queue.size() >= 1:
		return
	
	input_queue.push_back(direction)
