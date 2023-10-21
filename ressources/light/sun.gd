extends PointLight2D
class_name Sun
## Light that follow the x position of the player and use a Curve to determine it's luminosity.

## Adjust the curve for the intensity you went. 0 and 1 = 12am, 0.5 = 12pm
@export var light_curve : Curve
@export var time_speed : float = 0.1

# Variable used to progress in the curve
var light_offset : float = 0

func _process(delta : float) -> void:
	light_offset += time_speed * delta
	if light_offset > 1:
		light_offset = 0
	energy = light_curve.sample(light_offset)
	global_position.x = NodeLinker.player.global_position.x

func get_time(time : float) -> String:
	if time < 0 || time > 1:
		push_error("Time must be between 0 and 1")
		return ""
	var light_in_min : float = time * 24
	var hours : String = str(floor(light_in_min))
	if hours.length() == 1:
		hours = "0" + hours
	var minutes : String = str(floor(fmod(light_in_min,1) * 60))
	if minutes.length() == 1:
		minutes = "0" + minutes
	return hours + ":" + minutes

func get_time_float(time : String) -> float:
	var split : PackedStringArray = time.split(":")
	if split.size() != 2 || split[0].length() != 2 || split[1].length() != 2:
		push_error("Incorrect time format(24:60), " + time)
		return -1
	return (float(split[0]) + float(split[1]) / 60) / 24
