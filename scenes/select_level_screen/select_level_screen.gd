extends Control


@onready var v_box_container: VBoxContainer = $ScrollContainer/VBoxContainer

const BUTTON_THEME = preload("res://scenes/select_level_screen/button_theme.tres")

var levels: Array[PackedScene] = []

func _ready() -> void:
	# Not an ideal solution
	const LEVEL_ONE = preload("res://scenes/levels/level_one/level_one.tscn")
	const LEVEL_TWO = preload("res://scenes/levels/level_two/level_two.tscn")
	levels.push_back(LEVEL_ONE)
	levels.push_back(LEVEL_TWO)
	
	var i: int = 0
	for level in levels:
		i += 1
		var button: Button = Button.new()
		button.theme = BUTTON_THEME
		button.text = "Level {number}".format({"number": i})
		button.pressed.connect(change_scene.bind(level))
		v_box_container.add_child(button)

func change_scene(new_scene: PackedScene):
	get_tree().change_scene_to_packed(new_scene)
