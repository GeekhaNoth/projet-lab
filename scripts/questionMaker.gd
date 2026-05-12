extends Node
@export var buttonCreateQuestion : Button
@export var buttonCreateScene : Button
@export var buttonAddImage : Button
@export var textEdit : TextEdit
@export var allTextEdit: Node2D

@onready var file_dialog = $FileDialog
@onready var option_button = $OptionButton
@onready var lineEdit = [ $TextEdit/Answer1Edit, $TextEdit/Answer2Edit, $TextEdit/Answer3Edit, $TextEdit/Answer4Edit]

var selected_image_path := ""
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	buttonCreateQuestion.pressed.connect(CreateQuestion)
	buttonCreateScene.pressed.connect(CreateScene)
	buttonAddImage.pressed.connect(PutVisibleFileDialog)
	changeNodeVisibility(false)
	for i in range(lineEdit.size()):
		lineEdit[i].text_changed.connect(_on_answer_edit_text_changed.bind(i))
		if i > 0:
			lineEdit[i].set_visible(false)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func CreateScene():
	changeNodeVisibility(false)
	buttonCreateQuestion.hide()
	var sceneQuestion = preload("res://scene/questionScene.tscn").instantiate()
	add_child(sceneQuestion)
	var textNodeQuestion = sceneQuestion.get_node("Question/Texte/texte_personnalise")
	if (textEdit.text != ""):
		textNodeQuestion.text = textEdit.text
	var index = 0
	for text in allTextEdit.get_children():
		if (text.text != ""):
			sceneQuestion.buttons[index-1].get_child(0).text = text.text
		index += 1
		addInCsv(allTextEdit)
	ImportAndAddImage(sceneQuestion)
	
func ImportAndAddImage(nodeSceneQuestion):
	var image = Image.new()
	var err = image.load(selected_image_path)
	
	if err == OK:
		var texture = ImageTexture.create_from_image(image)
		nodeSceneQuestion.get_node("TextureRect").texture = texture

func CreateQuestion():
	buttonCreateQuestion.hide()
	changeNodeVisibility(true)
	pass
	
func addInCsv(allStringsToAdd):
	var csvFileRoot = "user://quiz.csv"
	var csvFile
	
	if FileAccess.file_exists(csvFileRoot):
		csvFile = FileAccess.open(csvFileRoot, FileAccess.READ_WRITE)
		csvFile.seek_end()
	else:
		csvFile = FileAccess.open(csvFileRoot, FileAccess.WRITE)
	var string = []
	for child in allStringsToAdd.get_children():
		string.append('"%s"' % child.text)
	csvFile.store_line(",".join(string))
	csvFile.close()

func changeNodeVisibility(state):
	buttonCreateScene.set_visible(state)
	allTextEdit.set_visible(state)
	buttonAddImage.set_visible(state)
	option_button.set_visible(state)


func PutVisibleFileDialog():
	file_dialog.popup_centered()

func _on_file_dialog_file_selected(path):
	selected_image_path = path
	buttonAddImage.get_child(0).set_visible(true)


func _on_answer_edit_text_changed(new_text, index) -> void:
	if option_button.item > index:
		option_button.set_item_text(index, new_text)
	else:
		option_button.add_item(new_text, index)
	pass # Replace with function body.

func AddAnAnswer():
	pass
