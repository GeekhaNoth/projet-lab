extends Node2D
@export var buttons: Array[TextureButton] = []

@onready var question_text = $Question/QuestionText

@onready var right = AudioStreamPlayer.new()
@onready var wrong = AudioStreamPlayer.new()

enum ButtonState {
	NORMAL,
	HOVER,
	CORRECT,
	WRONG
}

var sprites = {}

var index_csv = 0
var csv_rows = []
var csv_rows_interne = []

var right_answer
var score = 0

var number_question = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	Autoload.register_buttons(self)
	number_question = Autoload.number_question
	for button in get_tree().get_nodes_in_group("quiz_buttons"):
		var path = "res://sprites/AnswersAssets/" + button.name
		sprites[button] = load_button_sprites(path)
		
		button.pressed.connect(_on_button_pressed.bind(button))
		button.mouse_entered.connect(_on_button_hover.bind(button))
		button.mouse_exited.connect(_on_button_exit.bind(button))
	
	add_child(right)
	add_child(wrong)
	
	right.stream = preload("res://sound/right_answer.mp3")
	wrong.stream = preload("res://sound/wrong_answer.wav")
		
	load_csv()
	_check_if_enough_questions()
	_randomize_question()
	_new_question()

func _play_sound(sound):
	sound.play()

func _check_if_enough_questions():
	if (csv_rows.size() < number_question):
		var csv_file_interne = FileAccess.open("res://data/imported.json", FileAccess.READ)
		var content = csv_file_interne.get_as_text()
		var data = JSON.parse_string(content)
		for row in data:
			csv_rows_interne.append(row)
		#while not csv_file_interne.eof_reached():
			#csv_rows_interne.append(csv_file_interne.get_csv_line(";"))
			
		csv_file_interne.close()
	csv_rows_interne.shuffle()
	var index = 0
	while csv_rows.size() < number_question:
		csv_rows.append(csv_rows_interne[index])
		index += 1

func _randomize_question():
	csv_rows.shuffle()

func load_csv():
	var csv_file
	if (FileAccess.file_exists("user://quiz.csv")):
		csv_file = FileAccess.open("user://quiz.csv", FileAccess.READ)
	else:
		return
	
	while true:
		var line = csv_file.get_csv_line(";")

		if line.size() == 0 or line[0].strip_edges() == "":
			break

		print(line)
		csv_rows.append(line)
		print(str(csv_rows))
	csv_file.close()

func _undisplay_buttons():
	for button in buttons:
		button.set_visible(false)

func _new_question():
	
	_undisplay_buttons()
	$CounterQuestion.text = "Question n°" + str(index_csv+1)
	var csv_line = csv_rows[index_csv]
	print(str(csv_line))
	question_text.text = csv_line[0]
	var last_index = csv_line.size()-1
	last_index += _image_setup(csv_line[last_index])
	right_answer = csv_line[last_index]
	_display_button(last_index,  _randomize_answer(last_index, csv_line))

func _randomize_answer(last_index, csv_line):
	var new_array = []
	for i in range(1, last_index):
		new_array.append(csv_line[i])
	new_array.shuffle()
	return new_array

func _image_setup(location) -> int:
	if (_image_check(location)):
		$ImageContainer/Image.texture = _load_image_texture("user://images/" + location)
		return -1
	else:
		$ImageContainer/Image.texture = null
		return 0

func _display_button(last_index, array_shuffle):
	for i in range(0, last_index-1):
		buttons[i].set_visible(true)
		buttons[i].get_child(0).text = array_shuffle[i]

func _end_quiz_check():
	if (index_csv >= number_question):
		get_tree().change_scene_to_file("res://scene/main_scene.tscn")
		return

func _image_check(location):
	var path_image = "user://images/" + location
	return FileAccess.file_exists(path_image)

func _load_image_texture(path_image):
	var img = Image.load_from_file(path_image)
	return ImageTexture.create_from_image(img)

func _on_button_pressed(button_pressed : TextureButton):
	var correct = _is_answer_correct(button_pressed)
	if (correct):
		score += 1
		$Score.text = "Score : " + str(score)
		_play_sound(right)
	else:
		_play_sound(wrong)
		for button in buttons:
			if (button.get_child(0).text == right_answer):
				_set_button_state(button, ButtonState.CORRECT)
	_set_button_state(button_pressed, ButtonState.CORRECT if correct else ButtonState.WRONG)
	index_csv += 1
	_prepare_new_question(button_pressed)

func _prepare_new_question(button_pressed):
	button_pressed.disabled = true
	await get_tree().create_timer(0.5).timeout
	for button in buttons:
		if (button.texture_normal != sprites[button]["normal"]):
			_set_button_state(button, ButtonState.NORMAL)
	button_pressed.disabled = false
	if index_csv >= number_question:
		get_tree().change_scene_to_file("res://scene/main_scene.tscn")
		return
	_new_question()

func _is_answer_correct(button) -> bool:
	return button.get_child(0).text == right_answer

func load_button_sprites(path: String):
	var state = {}
	
	state["normal"] = load(path + "/normal.png")
	state["hover"] = load(path + "/hover.png")
	state["correct"] = load(path + "/correct.png")
	state["wrong"] = load(path + "/wrong.png")
	
	return state

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
