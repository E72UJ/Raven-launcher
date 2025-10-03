extends Button


func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://about.tscn")
	print("启动关于页面")
	pass # Replace with function body.
