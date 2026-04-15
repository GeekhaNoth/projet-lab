@tool
extends Node2D
@export var texte = true
@export var BonneRéponse = 1
@export var image = true

@onready var nodetxt = get_tree().get_nodes_in_group("txt")
@onready var nodesprite = get_tree().get_nodes_in_group("sprite")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Engine.is_editor_hint():
		for textChild in nodetxt:
			var textGenArray = textChild.find_children("texte_personnalise")
			var textPlaceholderArray = textChild.find_children("texte_generique")
			for text in textGenArray:
				if texte == true:
					text.show()
				else:
					text.hide()
			for text in textPlaceholderArray:
				if texte == true:
					text.hide()
				else:
					text.show()
		
