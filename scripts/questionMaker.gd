extends Node
@export var buttonCreateQuestion : Button
@export var buttonCreateScene : Button
@export var textEdit : TextEdit
@export var allTextEdit: Node2D

var allAnswersArray = []

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
		addInCsv(allTextEdit)
		for string in allAnswersArray:
			var index = allAnswersArray.find(string, 0)
			sceneQuestion.buttons[index-1].text = string

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
	for child in allStringsToAdd.get_children():
		allAnswersArray.append('"%s"' % child.text)
	csvFile.store_line(",".join(allAnswersArray))
	csvFile.close()
	
func changeNodeVisibility(state):
	buttonCreateScene.set_visible(state)
	allTextEdit.set_visible(state)
