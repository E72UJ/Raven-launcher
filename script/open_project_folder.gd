extends Button
@onready var ProjectPath = $"../../Right/ProjectPath"

func _on_pressed() -> void:
	var project_path = ProjectPath.text.strip_edges()
	
	if project_path.is_empty():
		print("路径为空")
		return
	
	if not DirAccess.dir_exists_absolute(project_path):
		print("路径不存在: ", project_path)
		return
	
	print("打开路径: ", project_path)
	
	# 将反斜杠转换为正斜杠（Windows兼容）
	var normalized_path = project_path.replace("\\", "/")
	
	var os_name = OS.get_name()
	
	if os_name == "Windows":
		# Windows 特殊处理：使用 cmd 命令
		var cmd = 'start "" "' + normalized_path + '"'
		OS.execute("cmd", ["/c", cmd])
	else:
		# 其他系统
		match os_name:
			"macOS":
				OS.execute("open", [normalized_path])
			"Linux":
				OS.execute("xdg-open", [normalized_path])
			_:
				OS.shell_open(normalized_path)
