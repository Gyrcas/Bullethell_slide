extends GPUParticles2D

@onready var blast : GPUParticles2D = $blast

func _ready() -> void:
	$disapear_timer.start(lifetime)
	emitting = true
	blast.lifetime = lifetime
	blast.process_material.scale_max *= lifetime / 2
	blast.process_material.color = process_material.color
	blast.process_material.scale_min = blast.process_material.scale_max
	blast.emitting = true


func _on_disapear_timer_timeout() -> void:
	get_parent().remove_child.call_deferred(self)
