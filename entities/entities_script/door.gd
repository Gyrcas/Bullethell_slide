@tool
extends StaticBody2D
class_name Door

@onready var col : CollisionShape2D = $col

@onready var start_position : Vector2 = global_position

@onready var sprite : TextureRect = $sprite
@export var texture : Texture2D : set = set_texture

@export var color : Color = Color(1,1,1) : set = set_color

func set_color(value : Color) -> void:
	color = value
	if sprite:
		sprite.self_modulate = value
	else:
		set_color.call_deferred(value)

func set_texture(value : Texture2D) -> void:
	texture = value
	if sprite:
		sprite.texture = texture
		sprite.size = dimensions
	else:
		set_texture.call_deferred(value)
	

@export var time : float = 1.0
@export var dimensions : Vector2 = Vector2(50,100) : set = set_dimensions
var opened : bool = false

func set_dimensions(value : Vector2) -> void:
	dimensions = value
	if col && sprite:
		col.position = dimensions / 2
		col.shape.size = dimensions
		sprite.size = dimensions
	else:
		set_dimensions.call_deferred(dimensions)

func open(anim : bool = true) -> void:
	opened = true
	move_door(start_position - global_transform.y * dimensions.y,anim)

func move_door(pos : Vector2, anim : bool = true) -> void:
	if anim:
		var tween : Tween = create_tween()
		tween.tween_property(self,"global_position",pos,time)
	else:
		global_position = pos

func close(anim : bool = true) -> void:
	opened = false
	move_door(start_position,anim)
