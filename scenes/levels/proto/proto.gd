extends Level

@onready var player: Player = $Player
@onready var grid_draw: GridDraw = $GridDraw

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.TILE_SIZE = TILE_SIZE
	player.rows = rows
	player.cols = cols
	player.initial_grid_pos = Vector2i(1, 1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
