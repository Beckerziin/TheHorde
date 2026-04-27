extends CanvasLayer

func changeScene(target: String) -> void:
	$AnimationPlayer.play("dissolve")
	await $AnimationPlayer.animation_finished
	await get_tree().change_scene_to_file(target)
	$AnimationPlayer.play_backwards("dissolve")
