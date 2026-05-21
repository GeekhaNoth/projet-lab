@tool
extends Node2D
@export var buttons: Array[TextureButton] = []

@onready var question_text = $Question/QuestionText

enum ButtonState {
	NORMAL,
	HOVER,
	CORRECT,
	WRONG
}

var sprites = {}

var index_csv = 0
var csv_rows = []

var right_answer

# Called when the node enters the scene tree for the first time.
func _ready():
	for button in get_tree().get_nodes_in_group("quiz_buttons"):
		var button_name = button.name
		var path = "res://sprites/" + button.name
		sprites[button] = load_button_sprites(path)
		
		button.pressed.connect(_on_button_pressed.bind(button))
		button.mouse_entered.connect(_on_button_hover.bind(button))
		button.mouse_exited.connect(_on_button_exit.bind(button))
		
	load_csv()
	_new_question()

func load_csv():
	var csv_file
	if (FileAccess.file_exists("user://quiz.csv")):
		csv_file = FileAccess.open("user://quiz.csv", FileAccess.READ)
	else:
		return
	
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
	
	question_text.text = csv_line[0]
	var last_index = csv_line.size()-1
	var has_image = FileAccess.file_exists(csv_line[last_index])
	if (has_image):
		$Sprite2D4/TextureRect.texture = load(csv_line[last_index])
		last_index -= 1
		
	right_answer = csv_line[last_index]
	for i in range(1, last_index):
		buttons[i-1].get_child(0).text = csv_line[i]
	
func _on_button_pressed(button_pressed : TextureButton):
	var correct = _is_answer_correct(button_pressed)
	_set_button_state(button_pressed, ButtonState.CORRECT if correct else ButtonState.WRONG)
	index_csv += 1
	button_pressed.disabled = true
	await get_tree().create_timer(0.5).timeout
	_set_button_state(button_pressed, ButtonState.NORMAL)
	button_pressed.disabled = false
	_new_question()

func _is_answer_correct(button) -> bool:
	return button.get_child(0).text == right_answer
	
func load_button_sprites(path: String):
	var result = {}
	
	result["normal"] = load(path + "/normal.png")
	result["hover"] = load(path + "/hover.png")
	result["correct"] = load(path + "/correct.png")
	result["wrong"] = load(path + "/wrong.png")
	
	return result

func _set_button_state(button, state: ButtonState):
	match state:
		ButtonState.NORMAL:
			button.texture_normal = sprites[button]["normal"]
		ButtonState.HOVER:
			button.texture_normal = sprites[button]["hover"]
		ButtonState.CORRECT:
			button.texture_normal = sprites[button]["correct"]
		ButtonState.WRONG:
			button.texture_normal = sprites[button]["wrong"]
			
func _on_button_hover(button):
	_set_button_state(button, ButtonState.HOVER)
	
func _on_button_exit(button):
	_set_button_state(button, ButtonState.NORMAL)
