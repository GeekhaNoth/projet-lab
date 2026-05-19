@tool
extends Node2D
@export var right_answer = 0
@export var buttons: Array[TextureButton] = []

@onready var question_text = $Question/QuestionText

var index_csv = 0
var csv_rows = []
# Called when the node enters the scene tree for the first time.
func _ready():
	for button in buttons:
		button.pressed.connect(_on_button_pressed.bind(button))
	load_csv()
	_new_question()

func load_csv():
	var csv_file = FileAccess.open("user://quiz.csv", FileAccess.READ)
	
	while not csv_file.eof_reached():
		csv_rows.append(csv_file.get_csv_line(";"))
	
	csv_file.close()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
func _new_question():
	if (index_csv +1 >= csv_rows.size()):
		get_tree().change_scene_to_file("res://scene/main_scene.tscn")
		
	var csv_line = csv_rows[index_csv]
	for i in range(csv_line.size()):
		if (i == 0): question_text.text = csv_line[0]
		else:
			buttons[i-1].get_child(0).text = csv_line[i]
	
func _on_button_pressed(button_pressed : TextureButton):
	var index = buttons.find(button_pressed)
	var sprites_node
	if index == right_answer:
		sprites_node = _get_texture_button_answer("Bonne Réponse", button_pressed)
	else:
		sprites_node = _get_texture_button_answer("Mauvaise Réponse", button_pressed)
	button_pressed.texture_normal = sprites_node.texture
	index_csv += 1
	button_pressed.disabled = true
	await get_tree().create_timer(0.5).timeout
	button_pressed.texture_normal = _get_texture_button_answer("Normal", button_pressed).texture
	button_pressed.disabled = false
	_new_question()
	
func _get_texture_button_answer(texture_name, button) -> Sprite2D:
	return button.get_parent().find_child(texture_name)
