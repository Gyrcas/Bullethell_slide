extends Interactable

func _on_save_zone_body_entered(body : Node2D) -> void:
	if body is Player:
		body.interaction = self

func _on_save_zone_body_exited(body : Node2D) -> void:
	if body is Player:
		body.interaction = null

func interact() -> void:
	print(get_tree().current_scene.scene_file_path)
