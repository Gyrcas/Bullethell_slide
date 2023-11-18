extends Area2D
class_name LaserTrap

@export var laser : Laser

@export var gs_active : String = "dash_aquired"

func _ready() -> void:
	if !GS.data.get(gs_active):
		laser.close(true)
		connect("body_entered",open_laser)
	else:
		laser.open(true)
		queue_free()

func open_laser(body : Node2D) -> void:
	if body is Player:
		laser.open()
		queue_free()
