extends Button

func change_to_root_scene():
	# 确保在主线程中调用
	if not is_inside_tree():
		print("错误：节点不在场景树中")
		return

	call_deferred("_change_scene")
func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://Root.tscn")
	pass # Replace with function body.
