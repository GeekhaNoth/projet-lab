extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(texture_normal.get_image())
	texture_click_mask = bitmap
