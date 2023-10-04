extends Node2D
class_name Target

func _ready() -> void:
	$AnimationPlayer.play("target")

@onready var two_click_target_timer : Timer = $two_click_target_timer

const target_node_name : String = "target_node"

const two_click_target_time : float = 0.2

var follow_mouse : bool = true
var can_place_target : bool = true
var current_target : Node2D = self

signal target_lost

func _on_two_click_target_timer_timeout() -> void:
	two_click_target_timer.stop()

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("right_click"):
		can_place_target = true
		visible = true
		if two_click_target_timer.is_stopped():
			two_click_target_timer.start(two_click_target_time)
		else:
			visible = false
			follow_mouse = true
			can_place_target = false
			two_click_target_timer.stop()

func change_target(new_target : Node2D) -> void:
	if new_target != self:
		visible = true
		follow_mouse = false
		var tar_node : Node2D = new_target.get_node_or_null(target_node_name)
		if tar_node:
			new_target = tar_node
	current_target = new_target

func _process(_delta : float) -> void:
	if !current_target:
		visible = false
		follow_mouse = true
		target_lost.emit()
		
	if Input.is_action_pressed("right_click") && can_place_target:
		if current_target != self:
			change_target(self)
		global_position = get_global_mouse_position()
		follow_mouse = false
	elif follow_mouse:
		global_position = get_global_mouse_position()
	elif current_target != self:
		global_position = current_target.global_position
