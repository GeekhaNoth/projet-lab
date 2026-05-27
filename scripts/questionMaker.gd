extends Node
@export var button_create_question : Button
@export var button_validate_question : Button
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
	button_validate_question.get_child(0).set_visible(false)
	$CounterNumberQuestion.text = "Nombre de question crées : " + str(_counter_number_line())
	_setup_button()

func _setup_button():
	for i in range(line_edit.size()):
		line_edit[i].text_changed.connect(_on_answer_edit_text_changed.bind(i))
		if (i > 0):
			line_edit[i].get_parent().pressed.connect(_add_an_answer.bind(line_edit[i].get_parent()))

func _counter_number_line() -> int:
	var file = FileAccess.get_file_as_string("user://quiz.csv")
	if not (file):
		return 0
	return file.strip_edges().split("\n").size()

func _validate_question():
	if (!_check_field_when_question_validation(question_edit, "Le champ question est vide")):
		return
	if (!_check_field_when_question_validation(line_edit[0], "Le champ réponse 1 est vide")):
		return
	#_setup_visibility_when_question_validate()
	_add_in_csv()
	get_tree().reload_current_scene()

func _setup_visibility_when_question_validate():
	button_validate_question.get_child(0).set_visible(false)
	_change_node_visibility(false)
	for element in line_edit:
		element.get_parent().set_visible(false)

func _check_field_when_question_validation(field_to_check, text_to_show) -> bool:
	if (field_to_check.text.strip_edges() == ""):
		button_validate_question.get_child(0).text = text_to_show
		button_validate_question.get_child(0).set_visible(true)
		return false
	return true

func _create_question():
	button_create_question.hide()
	_change_node_visibility(true)

func _add_in_csv():
	var csv_file = _check_if_csv_exist()
	csv_file.seek_end()
	
	var string = _put_all_texts_in_csv()
	if (selected_image_path != ""):
		string.append(_put_img_in_csv())
		
	csv_file.store_csv_line(string, ";")
	csv_file.close()	

func _put_all_texts_in_csv():
	var string_to_csv = []
	string_to_csv.append(question_edit.text)
	for element in line_edit:
		if (element.text.strip_edges() != ""):
			string_to_csv.append(element.text)
	
	string_to_csv.append(option_button.get_item_text(option_button.selected))
	return string_to_csv

func _put_img_in_csv() -> String:
		var img_name = selected_image_path.get_file()
		var img_folder = "user://images/"
		DirAccess.make_dir_recursive_absolute(img_folder)
		var target_path = img_folder + img_name
		DirAccess.copy_absolute(selected_image_path, target_path)
		return img_name

func _check_if_csv_exist():
	var csv_file_root = "user://quiz.csv"
	if (FileAccess.file_exists(csv_file_root)):
		var file = FileAccess.open(csv_file_root, FileAccess.READ_WRITE)
		return file
	else:
		return FileAccess.open(csv_file_root, FileAccess.WRITE_READ)

func _change_node_visibility(state):
	button_validate_question.set_visible(state)
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
		
	_check_lineEdit_text(new_text, index)

func _check_lineEdit_text(new_text, index):
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

func _back_to_menu():
	get_tree().change_scene_to_file("res://scene/main_scene.tscn")
