extends Control

var number_question = 1
var question_create

var total_question = 40

@onready var label_number_questions = $MarginContainer/VBoxContainer/CenterContainer/HBoxContainer/TextureRect2/Label2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Autoload.register_buttons(self)
	question_create = _counter_number_line()
	$MarginContainer/VBoxContainer/CenterContainer/HBoxContainer/Button.pressed.connect(_add_to_number_question.bind(-1))
	$MarginContainer/VBoxContainer/CenterContainer/HBoxContainer/Button2.pressed.connect(_add_to_number_question.bind(1))
	print(str(Autoload.number_question_create))
	total_question = 40 + question_create
	number_question = question_create
	label_number_questions.text = str(number_question)

func _counter_number_line() -> int:
	var file = FileAccess.get_file_as_string("user://quiz.csv")
	if not (file):
		return 0
	var number_create = file.strip_edges().split("\n").size()
	Autoload.number_question_create = number_create
	return number_create

func _add_to_number_question(add : int):
	number_question += add
	if (number_question < 1):
		number_question = total_question
	elif (number_question > total_question):
		number_question = 1
	label_number_questions.text = str(number_question)

func _launch_quiz():
	Autoload.number_question = number_question
	get_tree().change_scene_to_file("res://scene/question_scene.tscn")


func _on_back_home_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/main_scene.tscn")
