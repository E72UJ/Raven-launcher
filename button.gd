extends Button

func _on_pressed() -> void:
	print(12)
	
	# 简洁版本 - 输出基本目录信息（Godot 4 兼容）
	print("=== 目录信息 ===")
	print("操作系统: ", OS.get_name())
	print("可执行文件路径: ", OS.get_executable_path())
	print("可执行文件目录: ", OS.get_executable_path().get_base_dir())
	print("用户数据目录: ", OS.get_user_data_dir())
	
	# 获取环境变量
	var home = ""
	match OS.get_name():
		"macOS", "Linux":
			home = OS.get_environment("HOME")
		"Windows":
			home = OS.get_environment("USERPROFILE")
	
	if not home.is_empty():
		print("用户主目录: ", home)
	
	print("===============")
	
	# 打开用户数据目录的上一层目录
	open_user_data_parent_directory()

# 打开用户数据目录的上一层目录
func open_user_data_parent_directory():
	var user_data_dir = OS.get_user_data_dir()
	var parent_dir = user_data_dir.get_base_dir()
	
	# 确保目录存在
	if not DirAccess.dir_exists_absolute(user_data_dir):
		print("用户数据目录不存在，正在创建...")
		DirAccess.open("user://") # 这会自动创建用户数据目录
	
	print("用户数据目录: ", user_data_dir)
	print("正在打开上一层目录: ", parent_dir)
	
	# 根据不同操作系统使用不同命令打开文件管理器
	var error = -1
	match OS.get_name():
		"Windows":
			error = OS.execute("explorer", [parent_dir])
		"macOS":
			error = OS.execute("open", [parent_dir])
		"Linux":
			# Linux 尝试多个可能的文件管理器
			if OS.execute("xdg-open", [parent_dir]) != 0:
				if OS.execute("nautilus", [parent_dir]) != 0:
					if OS.execute("dolphin", [parent_dir]) != 0:
						OS.execute("thunar", [parent_dir])
	
	if error == 0:
		print("✓ 成功打开上一层目录")
	else:
		print("✗ 打开目录失败，请手动访问: ", parent_dir)
