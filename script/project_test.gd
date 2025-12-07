extends Button

func _on_pressed() -> void:
	print("执行项目检查")
	execute_cargo_check()

func execute_cargo_check():
	# 获取当前项目路径（假设 Rust 项目在 Godot 项目的上级目录或同级目录）
	get_tree().change_scene_to_file("res://check.tscn")
