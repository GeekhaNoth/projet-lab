extends Node2D

var number_question = 1
@onready var label_number_questions = $Label2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Autoload.register_buttons(self)
	$Button.pressed.connect(_add_to_number_question.bind(-1))
	$Button2.pressed.connect(_add_to_number_question.bind(1))
	pass # Replace with function body.



func _add_to_number_question(add : int):
	number_question += add
	if (number_question < 1):
		number_question = 40
	elif (number_question > 40):
		number_question = 1
	label_number_questions.text = str(number_question)

func _launch_quiz():
	Autoload.number_question = number_question
	get_tree().change_scene_to_file("res://scene/question_scene.tscn")


func _on_back_home_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/main_scene.tscn")
