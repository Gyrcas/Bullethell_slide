@tool
extends Sprite2D
class_name Scatter2D

@export var scatter_texture : Texture2D : set = set_scatter_texture

func set_scatter_texture(value : Texture2D) -> void:
	scatter_texture = value
	if preload_scatter:
		generate(seed_)

		
func _set(property : StringName, value : Variant) -> bool:
	if property == "texture":
		texture = value
		if preload_scatter:
			generate(seed_)
		return true
	return false

@export var resolution : Vector2i = Vector2i(1280,720) : set = set_resolution

func set_resolution(value : Vector2i) -> void:
	resolution = value
	if preload_scatter:
		generate(seed_)

@export_group("Seed")
@export var seed_ : int = 12345678 : set = set_seed_

func set_seed_(value : int) -> void:
	seed_ = value
	if preload_scatter:
		generate(seed_)

@export var use_seed : bool = true : set = set_use_seed

func set_use_seed(value : bool) -> void:
	use_seed = value
	set_preload_scatter(preload_scatter)

@export var preload_scatter : bool = true : set = set_preload_scatter

func set_preload_scatter(value : bool) -> void:
	if !use_seed:
		preload_scatter = false
	else:
		preload_scatter = value
		if preload_scatter:
			generate(seed_)
	if !preload_scatter:
		UT.remove_children(self)

@export_group("Params")
@export var dimensions : Vector2 = Vector2(100,100) : set = set_dimensions

func set_dimensions(value : Vector2) -> void:
	dimensions = value
	if preload_scatter:
		generate(seed_)

@export var min_scale : float = 1 : set = set_min_scale

func set_min_scale(value : float) -> void:
	min_scale = value
	if preload_scatter:
		generate(seed_)

@export var max_scale : float = 1 : set = set_max_scale

func set_max_scale(value : float) -> void:
	max_scale = value
	if preload_scatter:
		generate(seed_)

@export var min_distance : Vector2 = Vector2(500,500) : set = set_min_distance

func set_min_distance(value : Vector2) -> void:
	min_distance = value
	if preload_scatter:
		generate(seed_)

@export var max_distance : Vector2 = Vector2(2000,2000) : set = set_max_distance

func set_max_distance(value : Vector2) -> void:
	max_distance = value
	if preload_scatter:
		generate(seed_)

@export var rotate_range_min : float = 0 : set = set_rotate_range_min

func set_rotate_range_min(value : float) -> void:
	rotate_range_min = value
	if preload_scatter:
		generate(seed_)

@export var rotate_range_max : float = 60 : set = set_rotate_range_max

func set_rotate_range_max(value : float) -> void:
	rotate_range_max = value
	if preload_scatter:
		generate(seed_)

func _ready() -> void:
	if !Engine.is_editor_hint():
		if !preload_scatter && use_seed:
			generate(seed_)
		elif !use_seed:
			generate()

func create_sprite(node : Node2D,sprite : Sprite2D, pos : Vector2, rot : float) -> void:
	var new_sprite : Sprite2D = sprite.duplicate()
	new_sprite.position = pos
	new_sprite.rotation_degrees = rot
	node.add_child(new_sprite)

func generate(_seed : int = -1) -> int:
	if !Engine.is_editor_hint():
		return _seed
	UT.remove_children(self)
	if _seed < 0:
		randomize()
		_seed = randi_range(0,100000000)
	seed(_seed)
	var view : SubViewport = SubViewport.new()
	view.size = dimensions
	add_child(view)
	var background : ColorRect = ColorRect.new()
	background.color = Color(1,1,1)
	background.size = dimensions
	view.add_child(background)
	var node : Node2D = Node2D.new()
	view.add_child(node)
	var pos : Vector2 = Vector2.ZERO
	var sprite : Sprite2D = Sprite2D.new()
	sprite.texture = scatter_texture
	var sprite_scale : float = randf_range(min_scale,max_scale)
	sprite.scale = Vector2(sprite_scale,sprite_scale)
	while pos.x < dimensions.x || pos.y < dimensions.y:
		var sprite_pos : Vector2 = pos
		var pos_y : float = randf_range(min_distance.y,max_distance.y) * 1 if randi_range(-1,1) >= 0 else -1.0
		sprite_pos.y += pos_y if sprite_pos.y + pos_y < dimensions.y else dimensions.y
		create_sprite(node,sprite,sprite_pos, randf_range(rotate_range_min,rotate_range_max) * 1 if randf_range(-1,1) >= 0 else -1.0)
		pos.x += randf_range(min_distance.x, max_distance.x)
		if pos.x > dimensions.x && pos.y < dimensions.y:
			pos.y += (max_distance.y - min_distance.y) / 2 + min_distance.y
			pos.x = 0
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	await RenderingServer.frame_post_draw
	var view_texture : ViewportTexture = view.get_texture()
	var image : Image = view_texture.duplicate().get_image()
	image.resize(resolution.x,resolution.y)
	#image.flip_y()
	texture = ImageTexture.create_from_image(image)
	view.queue_free()
	return _seed
