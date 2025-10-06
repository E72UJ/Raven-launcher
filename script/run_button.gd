extends Button

@onready var status_label = $"../../StatusLabel"
@onready var ProjectPath = $"../../Right/ProjectPath"
func check_and_fix_permissions(exe_path: String) -> bool:
	if not FileAccess.file_exists(exe_path):
		print("文件不存在: ", exe_path)
		return false
	
	var output = []
	
	# 检查文件权限
	OS.execute("ls", ["-la", exe_path], output, true, true)
	print("文件权限信息:")
	for line in output:
		print(line)
	
	# 尝试添加执行权限
	var result = OS.execute("chmod", ["+x", exe_path], [], true, true)
	if result == 0:
		print("成功添加执行权限")
		return true
	else:
		print("添加权限失败，错误代码: ", result)
		return false
func launch_detached(exe_path: String, args: Array = []) -> bool:
	"""启动完全独立的进程，关闭启动器后程序依然运行 - 跨平台兼容版本"""
	
	var os_name = OS.get_name()
	print("检测到操作系统: ", os_name)
	
	# 只在 Unix 系统上检查权限
	if os_name != "Windows":
		if not check_and_fix_permissions(exe_path):
			print("权限设置失败")
			return false
	
	var success = false
	
	match os_name:
		"Windows":
			# Windows: 优先使用 OS.create_process (非阻塞)
			var pid = OS.create_process(exe_path, args)
			if pid > 0:
				print("Windows: 程序启动成功，进程ID: ", pid)
				success = true
			else:
				print("Windows: create_process 失败，尝试备用方法...")
				# 备用方法：使用 start 命令 + 非阻塞执行
				var start_args = ["/C", "start", "/B", "\"\"", exe_path]
				start_args.append_array(args)
				
				# 使用非阻塞方式执行
				var output = []
				var exit_code = OS.execute("cmd.exe", start_args, output, false, true)
				
				if exit_code == 0:
					print("Windows (备用): 程序启动成功")
					success = true
				else:
					print("Windows: 所有方法均失败，错误代码: ", exit_code)
		
		"macOS":
			# macOS: 根据文件类型选择启动方法
			if exe_path.ends_with(".app"):
				# .app 包使用 open 命令
				var open_args = ["-a", exe_path]
				if not args.is_empty():
					open_args.append("--args")
					open_args.append_array(args)
				var output = []
				var exit_code = OS.execute("open", open_args, output, false, true)
				
				if exit_code == 0:
					print("macOS: .app 包启动成功")
					success = true
				else:
					print("macOS: .app 启动失败")
			else:
				# 普通可执行文件使用 nohup
				var command = "nohup " + exe_path + " " + " ".join(args) + " &"
				var output = []
				var exit_code = OS.execute("/bin/sh", ["-c", command], output, false, true)
				
				if exit_code == 0:
					print("macOS: 程序启动成功")
					success = true
				else:
					print("macOS: 主方法失败，尝试备用方法...")
					# 备用方法
					var pid = OS.create_process(exe_path, args)
					if pid > 0:
						print("macOS (备用): 程序启动成功，进程ID: ", pid)
						success = true
					else:
						print("macOS: 所有方法均失败")
		
		"Linux":
			# Linux: 使用 nohup 启动独立进程
			var command = "nohup " + exe_path + " " + " ".join(args) + " &"
			var output = []
			var exit_code = OS.execute("/bin/sh", ["-c", command], output, false, true)
			
			if exit_code == 0:
				print("Linux: 程序启动成功")
				success = true
			else:
				print("Linux: 主方法失败，尝试备用方法...")
				# 备用方法
				var pid = OS.create_process(exe_path, args)
				if pid > 0:
					print("Linux (备用): 程序启动成功，进程ID: ", pid)
					success = true
				else:
					print("Linux: 所有方法均失败")
		
		_:
			# 未知平台或其他系统：使用通用方法
			print("未知系统，使用通用方法...")
			var pid = OS.create_process(exe_path, args)
			if pid > 0:
				print("通用方法: 程序启动成功，进程ID: ", pid)
				success = true
			else:
				print("通用方法: 程序启动失败，错误代码: ", pid)
	
	if success:
		print("程序已完全独立运行，可以安全关闭启动器")
	
	return success




func _on_pressed() -> void:
	var exe_path = ProjectPath.text + "/raven" + (".exe" if OS.get_name() == "Windows" else "")
	print(exe_path)

	var success = launch_detached(exe_path, ["arg1", "arg2"])
	if success:
		print("启动成功！现在可以关闭启动器了")
		# 可以选择自动关闭启动器
		# get_tree().quit()
	else:
		print("启动失败")


func _on_mouse_entered() -> void:
	status_label.text = self.text
	pass # Replace with function body.


func _on_mouse_exited() -> void:
	
	status_label.text = "就绪"
	pass # Replace with function body.
