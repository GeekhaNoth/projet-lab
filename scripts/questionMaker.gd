extends Node
@export var button_create_question : TextureButton
@export var button_validate_question : TextureButton
@export var button_add_image : TextureButton
@export var question_edit : TextEdit
@export var button_modify_question : TextureButton
@export var button_validate_modif : TextureButton

@onready var file_dialog = $FileDialog
@onready var option_button = $MarginContainer/VBoxContainer/TextEdit/GridContainer/OptionButton
@onready var line_edit = [ $MarginContainer/VBoxContainer/TextEdit/GridContainer/Answer1Edit, 
$MarginContainer/VBoxContainer/TextEdit/GridContainer/Answer2Edit, 
$MarginContainer/VBoxContainer/TextEdit/GridContainer/Answer3Edit, 
$MarginContainer/VBoxContainer/TextEdit/GridContainer/Answer4Edit]
@onready var container = $ScrollContainer

@onready var counter_node = $MarginContainer/VBoxContainer/Counter
@onready var counter_text = $MarginContainer/VBoxContainer/Counter/CounterNumberQuestion
@onready var modify_button = $MarginContainer/VBoxContainer/ModifyButton
@onready var modify_button_label = $MarginContainer/VBoxContainer/ModifyButton/TextureRect
@onready var reset_button_label = $Control/ButtonReset/TextureRect

@onready var error_node = $TextureRect
@onready var question_title = $QuestionTitle
@onready var button_validate = $MarginContainer/VBoxContainer/TextEdit/Questionasset/TextureButton

var selected_image_path := ""
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Autoload.register_buttons(self)
	_change_node_visibility(false)
	counter_text.text = str(_counter_number_line())
	counter_node.show()
	_setup_button()
	container.hide()
	_check_for_modify_button()

func _check_for_modify_button():
	if (FileAccess.get_file_as_bytes("user://quiz.csv").size() == 0):
		modify_button.mouse_entered.connect(_on_button_modify_disabled_mouse_entered)
		modify_button.mouse_exited.connect(_on_button_modify_disabled_mouse_exited)
		modify_button.disabled = true

func _on_button_modify_disabled_mouse_entered():
	modify_button_label.show()

func _on_button_modify_disabled_mouse_exited():
	modify_button_label.hide()

func _on_button_mouse_entered():
	reset_button_label.show()

func _on_button_mouse_exited():
	reset_button_label.hide()

func _setup_button():
	for i in range(line_edit.size()):
		line_edit[i].text_changed.connect(_on_answer_edit_text_changed.bind(i))

func _counter_number_line() -> int:
	var file = FileAccess.get_file_as_string("user://quiz.csv")
	if not (file):
		return 0
	var number_create = file.strip_edges().split("\n").size()
	Autoload.number_question_create = number_create
	return number_create

func _validate_question():
	if (!_check_field_when_question_validation(line_edit[0], "Le champ réponse 1 est vide")):
		return
	_setup_visibility_when_question_validate()
	_add_in_csv()
	get_tree().reload_current_scene()

func _setup_visibility_when_question_validate():
	error_node.set_visible(false)
	_change_node_visibility(false)

func _check_field_when_question_validation(field_to_check, text_to_show) -> bool:
	if (field_to_check.text.strip_edges() == ""):
		error_node.get_child(0).text = text_to_show
		error_node.set_visible(true)
		return false
	return true

func _hide_main_button():
	button_create_question.hide()
	button_modify_question.hide()

func _create_question():
	_hide_main_button()
	question_edit.get_parent().show()
	

func _validate_title_question():
	if (!_check_field_when_question_validation(question_edit, "Le champ question est vide")):
		return
	question_edit.get_parent().hide()
	line_edit[0].get_parent().show()
	question_title.show()
	option_button.show()
	button_add_image.show()
	question_title.text = question_edit.text
	if (error_node.visible == true):
		error_node.hide()
	button_validate_question.show()

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
		return target_path

func _check_if_csv_exist():
	var csv_file_root = "user://quiz.csv"
	if (FileAccess.file_exists(csv_file_root)):
		return FileAccess.open(csv_file_root, FileAccess.READ_WRITE)
	else:
		return FileAccess.open(csv_file_root, FileAccess.WRITE_READ)

func _change_node_visibility(state):
	question_edit.get_parent().set_visible(state)
	button_add_image.set_visible(state)
	line_edit[0].get_parent().set_visible(state)


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
		#option_button.set_item_icon(index, load("res://sprites/ModeCreation/UIProjetLabSelectAnswer.png"))
		var popup = option_button.get_popup()
		popup.add_theme_font_size_override("font_size", 24)

func _back_to_menu():
	get_tree().change_scene_to_file("res://scene/main_scene.tscn")

func _modify_question_menu():
	_hide_main_button()
	var csv_file = _check_if_csv_exist()
	_create_list_question(csv_file)
	
func _create_list_question(file):
	container.show()
	var csv_rows = []
	while not file.eof_reached():
		var line = file.get_csv_line(";")
		
		if line.size() == 0:
			continue
		
		if line[0].strip_edges() == "":
			continue
		csv_rows.append(line)
	for i in range(csv_rows.size()):
		if (i % 2 == 1 && i > 1):
			container.get_child(0).columns += 1
		var button = TextureButton.new()
		var text = Label.new()
		button.add_child(text)
		text.anchor_left = 0
		text.anchor_top = 0
		text.anchor_right = 1
		text.anchor_bottom = 1
		text.offset_left = 0
		text.offset_top = 0
		text.offset_right = 0
		text.offset_bottom = 0
		text.text = csv_rows[i][0]
		container.get_child(0).add_child(button)
		button.custom_minimum_size = Vector2(50, 50)
		button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		
		button.texture_normal = load("res://sprites/ModeCreation/UIProjetLabSelectAnswer.png")
		button.texture_hover = load("res://sprites/ModeCreation/UIProjetLabSelectAnswerHighlight.png")
		button.pressed.connect(Autoload._play_click)
		button.mouse_entered.connect(Autoload._play_click)
		text.add_theme_font_size_override("font_size", 48)
		text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		text. horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.pressed.connect(_modify_question.bind(csv_rows, i))
		
func _modify_question(csv_rows, index):
	container.hide()
	#option_button.show()
	var csv_line = csv_rows[index]
	question_edit.text = csv_line[0]
	question_edit.get_parent().show()
	var last_index = csv_line.size()-1
	last_index += _image_setup(csv_line[last_index])
	if (button_validate.pressed.is_connected(_validate_title_question)):
		button_validate.pressed.disconnect(_validate_title_question)
	button_validate.pressed.connect(_validate_modif_question_title.bind(last_index, csv_line, csv_rows, index), CONNECT_ONE_SHOT)

func _validate_modif_question_title(last_index, csv_line, csv_rows, index):
	if (!_check_field_when_question_validation(question_edit, "Le champ question est vide")):
		button_validate_modif.pressed.connect(_validate_modif_question_title.bind(last_index, csv_line, csv_rows, index), CONNECT_ONE_SHOT)
		return
	option_button.show()
	question_edit.get_parent().hide()
	line_edit[0].get_parent().show()
	for i in range(1, last_index):
		line_edit[i-1].text = csv_line[i]
		option_button.add_item(line_edit[i-1].text, i-1)
	button_validate_modif.show()
	button_validate_modif.pressed.connect(_make_modif_in_csv.bind(index, csv_rows), CONNECT_ONE_SHOT)

func _make_modif_in_csv(index, csv_rows):
	if (!_check_field_when_question_validation(line_edit[0], "Le champ réponse 1 est vide")):
		button_validate.pressed.connect(_make_modif_in_csv.bind(index, csv_rows), CONNECT_ONE_SHOT)
		return
	var string_to_csv = []
	string_to_csv.append(question_edit.text)
	for element in line_edit:
		if (element.text.strip_edges() != ""):
			string_to_csv.append(element.text)
	
	string_to_csv.append(option_button.get_item_text(option_button.selected))
	if (selected_image_path != ""):
		string_to_csv.append(_put_img_in_csv())
	csv_rows[index] = string_to_csv
	var file = FileAccess.open("user://quiz.csv", FileAccess.WRITE)
	for line in csv_rows:
		file.store_csv_line(line, ";")
	
	file.close()
	get_tree().reload_current_scene()

func _image_setup(location) -> int:
	if (_image_check(location)):
		return -1
	else:
		return 0

func _image_check(location):
	var path_image = location
	return FileAccess.file_exists(path_image)

func _reset_all_questions():
	DirAccess.remove_absolute("user://quiz.csv")
	get_tree().reload_current_scene()
