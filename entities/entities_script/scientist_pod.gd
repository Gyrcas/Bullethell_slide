@tool
extends Interactable
class_name ScientistPod

@onready var sprite : Sprite2D = $sprite
@export_range(0,14) var skin : int = 0 : set = set_skin

func set_skin(value : int) -> void:
	if !sprite:
		return
	skin = value
	sprite.frame = value
	
