extends Button


func _on_pressed() -> void:
	# 直接跳转到场景文件
	get_tree().change_scene_to_file("res://New_project.tscn")
	pass # Replace with function body.
