extends Area2D
class_name Interactable

signal interacted

func _on_zone_body_entered(body : Node2D) -> void:
	if body is Player:
		body.interaction = self

func _on_zone_body_exited(body : Node2D) -> void:
	if body is Player:
		body.interaction = null

func _ready() -> void:
	connect("body_entered",_on_zone_body_entered)
	connect("body_exited",_on_zone_body_exited)

func interact() -> void:
	if Global.player.dying:
		return
	interacted.emit()
