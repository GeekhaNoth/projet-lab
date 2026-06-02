extends Node2D

@onready var main_menu = $MainMenu
@onready var creation_button = $MainMenu/CreationButton
@onready var game_button = $MainMenu/CreationButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DirAccess.make_dir_recursive_absolute("user://images")

func _on_game_button_pressed():
	_change_scene("res://scene/quiz_option.tscn")

func _on_creation_button_pressed():
	_change_scene("res://scene/question_maker.tscn")

func _change_scene(scene_root):
	get_tree().change_scene_to_file(scene_root)
