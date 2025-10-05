extends Button

@onready var status_label = $"../../StatusLabel"

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
	"""启动完全独立的进程，关闭启动器后程序依然运行"""
	
	# 先检查并修复权限
	if not check_and_fix_permissions(exe_path):
		print("权限设置失败")
		return false
	
	# 使用 create_process 创建完全分离的进程
	# 第三个参数设为 false，表示不等待进程结束
	var pid = OS.create_process(exe_path, args, false)
	
	if pid > 0:
		print("程序启动成功，进程ID: ", pid)
		print("程序已完全独立运行，可以安全关闭启动器")
		return true
	else:
		print("程序启动失败，错误代码: ", pid)
		return false
func _on_pressed() -> void:
	print("执行数据")
	var success = launch_detached("/Users/furau/Documents/demo6/raven", ["arg1", "arg2"])
	if success:
		print("启动成功！现在可以关闭启动器了")
		# 可以选择自动关闭启动器
		# get_tree().quit()
	else:
		print("启动失败")
	pass # Replace with function body.


func _on_mouse_entered() -> void:
	status_label.text = self.text
	pass # Replace with function body.


func _on_mouse_exited() -> void:
	
	status_label.text = "就绪"
	pass # Replace with function body.
