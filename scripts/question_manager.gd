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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_button_pressed(_button : TextureButton):
	var index = buttons.find(_button, 0)
	var _spritesNode
	if index+1 == BonneRéponse:
		_spritesNode = _button.get_parent().find_child("Bonne Réponse")
	else:
		_spritesNode = _button.get_parent().find_child("Mauvaise Réponse")
	_button.texture_normal = _spritesNode.texture
	for button in buttons:
		button.disabled = true
