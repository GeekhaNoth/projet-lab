extends Node2D

@onready var main_menu = $MainMenu
@onready var creation_button = $MainMenu/CreationButton
@onready var game_button = $MainMenu/CreationButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_game_button_pressed():
	_change_scene("res://scene/question_scene.tscn")

func _on_creation_button_pressed():
	_change_scene("res://scene/question_maker.tscn")

func _change_scene(scene_root):
	get_tree().change_scene_to_file(scene_root)
