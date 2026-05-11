@tool
extends Node2D
@export var texte = true
@export var BonneRéponse = 1
@export var image = true
@export var buttons: Array[TextureButton] = []

@onready var nodetxt = get_tree().get_nodes_in_group("txt")
@onready var nodesprite = get_tree().get_nodes_in_group("sprite")

# Called when the node enters the scene tree for the first time.
func _ready():
	for button in buttons:
		button.pressed.connect(_on_button_pressed.bind(button))
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	#if Engine.is_editor_hint():
		#_changeNodesOfACategoryState(nodetxt, "texte_personnalise", "texte_generique", texte)

func _changeNodesOfACategoryState(_nodesCategory, stringNodeCustoms, stringNodeGen, boolCategory):
	for child in _nodesCategory:
		var allNodesOfCategoryGenArray = child.find_children(stringNodeCustoms)
		var allNodesOfCategoryPlaceholderArray = child.find_children(stringNodeGen)
		for element in allNodesOfCategoryGenArray:
			if boolCategory:
				element.set_visible(true)
			else:
				BonneRéponse = 2
				element.set_visible(false)
		for element in allNodesOfCategoryPlaceholderArray:
			if boolCategory:
				element.set_visible(false)
			else:
				BonneRéponse = 2
				element.set_visible(true)

func _changeNodeState(_node, _newState):
	_node.set_visible(_newState)


func _on_button_pressed(_button : Button):
	var index = buttons.find(_button, 0)
	var _spritesNode
	if index+1 == BonneRéponse:
		_spritesNode = _button.get_parent().find_child("Bonne Réponse")
	else:
		_spritesNode = _button.get_parent().find_child("Mauvaise Réponse")
	_button.icon = _spritesNode.texture
	for button in buttons:
		button.pressed.disconnect(_on_button_pressed.bind(button))
