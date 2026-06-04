extends Node

var number_question = 0
var number_question_create = 0

@onready var hover_player = AudioStreamPlayer.new()
@onready var click_player = AudioStreamPlayer.new()

func _ready():
	add_child(hover_player)
	add_child(click_player)
	
	hover_player.stream = preload("res://sound/ui_hover.mp3")
	click_player.stream = preload("res://sound/ui_click.wav")

func _play_hover():
	hover_player.play()

func _play_click():
	click_player.play()

func register_buttons(root: Node):
	_connect_buttons(root)
	
func _connect_buttons(node: Node):
	for child in node.get_children():
		if (child is BaseButton):
			child.mouse_entered.connect(func():
				if not child.disabled:
					_play_hover()
			)
			if not child.pressed.is_connected(_play_click):
				child.pressed.connect(_play_click)
		
		elif child is LineEdit || child is TextEdit:
			child.mouse_entered.connect(func():
				var style = child.get_theme_stylebox("normal").duplicate()
				style.bg_color.a = 0.15
				child.add_theme_stylebox_override("normal", style)
				_play_hover()
			)
			child.mouse_exited.connect(func():
				var style = child.get_theme_stylebox("normal").duplicate()
				style.bg_color.a = 0.0
				child.add_theme_stylebox_override("normal", style)
			)
		_connect_buttons(child)
