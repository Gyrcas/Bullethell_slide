@tool
extends MultiMeshInstance2D
class_name Scatter2D

@export var scatter_mesh : MeshInstance2D : set = set_scatter_mesh

func set_scatter_mesh(value : MeshInstance2D) -> void:
	scatter_mesh = value
	multimesh.mesh = scatter_mesh.mesh
	texture = scatter_mesh.texture
	if preload_scatter:
		generate(seed_)

		
func _set(property : StringName, value : Variant) -> bool:
	if property == "texture":
		texture = value
		if preload_scatter:
			generate(seed_)
		return true
	return false

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

func generate(_seed : int = -1) -> int:
	#Generate new seed if one not given
	if _seed < 0:
		randomize()
		_seed = randi_range(0,100000000)
	seed(_seed)
	
	multimesh.instance_count = 0
	var pos : Vector2 = Vector2.ZERO
	var instances_infos : Array[Dictionary] = []
	
	while pos.x < dimensions.x || pos.y < dimensions.y:
		multimesh.instance_count += 1
		
		var rot : float = deg_to_rad(randf_range(rotate_range_min,rotate_range_max))
		
		var sprite_scale : float = randf_range(min_scale,max_scale)
		
		var sprite_pos : Vector2 = pos
		var pos_y : float = randf_range(min_distance.y,max_distance.y) * 1 if randi_range(-1,1) >= 0 else -1.0
		sprite_pos.y += pos_y if sprite_pos.y + pos_y < dimensions.y else dimensions.y
		
		pos.x += randf_range(min_distance.x, max_distance.x)
		if pos.x > dimensions.x && pos.y < dimensions.y:
			pos.y += (max_distance.y - min_distance.y) / 2 + min_distance.y
			pos.x = 0
			
		instances_infos.append({"pos":sprite_pos,"rot":rot,"scale":Vector2(sprite_scale,sprite_scale)})
		
	for i in multimesh.instance_count:
		multimesh.set_instance_transform_2d(i,Transform2D(instances_infos[i].rot,instances_infos[i].scale,0.0,instances_infos[i].pos))
		
	return _seed
