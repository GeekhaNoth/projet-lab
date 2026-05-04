extends Node
@export var buttonCreateQuestion : Button
@export var buttonCreateScene : Button
@export var textEdit : TextEdit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	buttonCreateQuestion.pressed.connect(CreateQuestion)
	buttonCreateScene.pressed.connect(CreateScene)
	textEdit.hide()
	buttonCreateScene.hide()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func CreateScene():
	textEdit.hide()
	buttonCreateScene.hide()
	buttonCreateQuestion.hide()
	var sceneQuestion = preload("res://scene/questionScene.tscn").instantiate()
	add_child(sceneQuestion)
	var textNodeQuestion = sceneQuestion.get_node("Question/Texte/texte_personnalise")
	if (textEdit.text != ""):
		textNodeQuestion.text = textEdit.text
	else:
		var test = $SceneQuiz
		test.texte=false

func CreateQuestion():
	textEdit.show()
	buttonCreateScene.show()
	pass
