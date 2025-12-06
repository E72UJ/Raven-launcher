extends Button

func _on_pressed() -> void:
	print("执行项目检查")
	execute_cargo_check()

func execute_cargo_check():
	# 获取当前项目路径（假设 Rust 项目在 Godot 项目的上级目录或同级目录）
	var rust_project_path = "your_rust_project_path"  # 替换为实际路径
	
	# 执行 cargo check
	var output = []
	var exit_code = OS.execute("cargo", ["check"], output, true, true)
	
	if exit_code == 0:
		print("Cargo check 成功完成")
		print("输出: ", output)
	else:
		print("Cargo check 失败，退出码: ", exit_code)
		print("错误输出: ", output)
