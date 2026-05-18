extends Node
@export var button_create_question : Button
@export var button_create_scene : Button
@export var button_add_image : Button
@export var question_edit : TextEdit

@onready var file_dialog = $FileDialog
@onready var option_button = $OptionButton
@onready var line_edit = [ $TextEdit/Answer1Edit, 
$TextEdit/AddAnswer2Button/Answer2Edit, 
$TextEdit/AddAnswer3Button/Answer3Edit, 
$TextEdit/AddAnswer4Button/Answer4Edit]

var selected_image_path := ""
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_change_node_visibility(false)
	for i in range(line_edit.size()):
		line_edit[i].text_changed.connect(_on_answer_edit_text_changed.bind(i))
		if (i > 0):
			line_edit[i].get_parent().pressed.connect(_add_an_answer.bind(line_edit[i].get_parent()))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _validate_question():
	_change_node_visibility(false)
	for element in line_edit:
		element.get_parent().set_visible(false)
	var scene_question = preload("res://scene/questionScene.tscn").instantiate()
	add_child(scene_question)
	var question_text_node = scene_question.get_node("Question/QuestionText")
	if (question_edit.text != ""):
		question_text_node.text = question_edit.text
	for i in range(line_edit.size()):
		if (line_edit[i].text != ""):
			scene_question.buttons[i].get_child(0).text = line_edit[i].text
	_add_in_csv()
	_import_and_add_image(scene_question)
	scene_question.right_answer = option_button.get_selected_id()
	
func _import_and_add_image(node_scene_question):
	if(selected_image_path != ""):
			node_scene_question.get_node("Sprite2D4/TextureRect").texture = load(selected_image_path)

func _create_question():
	button_create_question.hide()
	_change_node_visibility(true)
	
func _add_in_csv():
	var csv_file_root = "user://quiz.csv"
	var csv_file
	
	if FileAccess.file_exists(csv_file_root):
		csv_file = FileAccess.open(csv_file_root, FileAccess.READ_WRITE)
		csv_file.seek_end()
	else:
		csv_file = FileAccess.open(csv_file_root, FileAccess.WRITE)
		
	var string = []
	string.append(question_edit.text)
	for element in line_edit:
		string.append(element.text)
	csv_file.store_csv_line(string, ";")
	csv_file.close()

func _change_node_visibility(state):
	button_create_scene.set_visible(state)
	question_edit.set_visible(state)
	button_add_image.set_visible(state)
	line_edit[0].set_visible(state)


func _put_visible_file_dialog():
	file_dialog.popup_centered()

func _on_file_dialog_file_selected(path):
	selected_image_path = path
	button_add_image.get_child(0).set_visible(true)


func _on_answer_edit_text_changed(new_text, index) -> void:
	if option_button.item_count > index:
		option_button.set_item_text(index, new_text)
	else:
		option_button.add_item(new_text, index)
		
	if (new_text == ""):
		if (line_edit.size() > index+1):
			line_edit[index+1].get_parent().set_visible(false)
	else:
		if (line_edit.size() > index+1):
			line_edit[index+1].get_parent().set_visible(true)

func _add_an_answer(button):
	if (option_button.visible == false):
		option_button.set_visible(true)
	button.get_child(0).set_visible(true)
	button.self_modulate.a = 0
