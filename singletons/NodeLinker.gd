extends Node

const bullet_scene : String = "res://scenes/bullet.tscn"

const main_menu : String = "res://debug/test.tscn"

const death_particles : String = "res://scenes/death_particles.tscn"

var player : Player = null

var translations : String = OS.get_executable_path().get_base_dir() + "/data/translation"
