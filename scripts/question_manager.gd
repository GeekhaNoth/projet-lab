@tool
extends Node2D
@export var right_answer = 0
@export var buttons: Array[TextureButton] = []

@onready var question_text = $Question/QuestionText

var csv_file
var index_csv = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	csv_file = FileAccess.open("user://quiz.csv", FileAccess.READ_WRITE)
	for button in buttons:
		button.pressed.connect(_on_button_pressed.bind(button))
	_new_question()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
func _new_question():
	var csv_line = csv_file.get_csv_line(index_csv)
	for i in range(csv_line.size()):
		if (i == 0): question_text.text = csv_line[0]
		else:
			buttons[i-1].get_child(0).text = csv_line[i]
	
func _on_button_pressed(button_pressed : TextureButton):
	var index = buttons.find(button_pressed)
	var sprites_node
	if index == right_answer:
		sprites_node = button_pressed.get_parent().find_child("Bonne Réponse")
	else:
		sprites_node = button_pressed.get_parent().find_child("Mauvaise Réponse")
	button_pressed.texture_normal = sprites_node.texture
	index_csv += 1
	_new_question()
