extends Node
@export var buttonCreateQuestion : Button
@export var buttonCreateScene : Button
@export var textEdit : TextEdit
@export var allTextEdit: Node2D

@onready var file_dialog = $FileDialog
@onready var preview = $TextureRect

var selected_image_path := ""
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	buttonCreateQuestion.pressed.connect(CreateQuestion)
	buttonCreateScene.pressed.connect(CreateScene)
	changeNodeVisibility(false)
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
		for textEdit in allTextEdit.get_children():
			sceneQuestion.buttons[index-1].get_child(0).text = textEdit.text
			index += 1
		addInCsv(allTextEdit)

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
	

func _on_button_pressed():
	file_dialog.popup_centered()

func _on_file_dialog_file_selected(path):
	selected_image_path = path
	var image = Image.new()
	var err = image.load(path)
	
	if err == OK:
		var texture = ImageTexture.create_from_image(image)
		preview.texture = texture
