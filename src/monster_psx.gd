extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.play(&"MonsterPSX_Rig|Walk_Nervous")

func play_walk() -> void:
	animation_player.play(&"MonsterPSX_Rig|Walk_Nervous")

func play_attack() -> void:
	animation_player.play(&"MonsterPSX_Rig|Scream_lol")
