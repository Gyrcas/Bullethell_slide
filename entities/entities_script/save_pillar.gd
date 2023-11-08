extends Interactable

func _on_save_zone_body_entered(body : Node2D) -> void:
	if body is Player:
		body.interaction = self

func _on_save_zone_body_exited(body : Node2D) -> void:
	if body is Player:
		body.interaction = null

func interact() -> void:
	Global.player.health = Global.player.health_max
	Global.player.pause_menu.open("save_pillar_menu",{"save_position":global_position})
	interacted.emit()
