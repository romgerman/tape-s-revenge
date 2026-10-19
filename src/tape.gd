extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var tape_end_attachment: BoneAttachment3D = $Tape_Armature/Skeleton3D/TapeEnd
@onready var tape_end2_attachment: BoneAttachment3D = $Tape_Armature/Skeleton3D/TapeEnd2
@onready var tape_stretch_sfx: AudioStreamPlayer3D = $Tape_Armature/Skeleton3D/TapeEnd/TapeStretch

signal target_reached()

func _ready() -> void:
	animation_player.play(&"Idle")

var attack_tw: Tween

func set_target_position(target_position: Vector3) -> void:
	if attack_tw:
		attack_tw.kill()
	
	animation_player.stop(true)
	
	tape_end_attachment.override_pose = true
	tape_end2_attachment.override_pose = true
	
	var local_position := global_transform.inverse() * target_position
	var dir := position.direction_to(local_position)
	var tape_end_pos := tape_end_attachment.position
	var tape_end2_pos := tape_end2_attachment.position
	
	attack_tw = create_tween().set_trans(Tween.TRANS_SINE)
	# Swing
	attack_tw.tween_property(tape_end_attachment, "position", -dir * 0.5, 0.1).set_ease(Tween.EASE_IN)
	attack_tw.parallel().tween_property(tape_end2_attachment, "position", -dir * 0.25, 0.1).set_ease(Tween.EASE_IN)
	# Reach
	attack_tw.tween_callback(func ():
		tape_stretch_sfx.pitch_scale = randf_range(0.9, 1.1)
		tape_stretch_sfx.play()
	)
	attack_tw.tween_property(tape_end_attachment, "position", local_position, 0.1).set_ease(Tween.EASE_OUT)
	attack_tw.parallel().tween_property(tape_end2_attachment, "position", dir * local_position.length() * 0.5, 0.1).set_ease(Tween.EASE_OUT)
	attack_tw.tween_callback(target_reached.emit)
	# Comeback
	attack_tw.tween_property(tape_end_attachment, "position", tape_end_pos, 0.35).set_ease(Tween.EASE_IN)
	attack_tw.parallel().tween_property(tape_end2_attachment, "position", tape_end2_pos, 0.35).set_ease(Tween.EASE_IN)
	# Reset
	attack_tw.tween_callback(func ():
		tape_end_attachment.override_pose = false
		tape_end2_attachment.override_pose = false
		animation_player.play(&"Idle")
	)
	
	await attack_tw.finished
