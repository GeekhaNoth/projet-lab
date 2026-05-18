extends Node2D

@onready var main_menu = $MainMenu
@onready var creation_button = $MainMenu/CreationButton
@onready var game_button = $MainMenu/CreationButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	creation_button.pressed.connect(_on_button_pressed.bind("res://scene/question_maker.tscn"))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed(scene_root):
	var scene_instantiate = load(scene_root).instantiate()
	main_menu.set_visible(false)
	add_child(scene_instantiate)
	pass # Replace with function body.
