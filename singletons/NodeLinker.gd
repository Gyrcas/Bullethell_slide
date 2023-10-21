extends Node

const bullet_scene : String = "res://entities/bullet.tscn"

const death_particles : String = "res://ressources/death_particles.tscn"

var player : Player = null

const auto_target_collision_level : int = 3

var translations : String = OS.get_executable_path().get_base_dir() + "/data/translation"
