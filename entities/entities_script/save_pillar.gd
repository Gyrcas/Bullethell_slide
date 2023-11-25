extends Interactable

func interact() -> void:
	if Global.player.dying:
		return
	interacted.emit()
	Global.player.health = Global.player.health_max
	Global.player.pause_menu.open("save_pillar_menu",{"save_position":global_position})
