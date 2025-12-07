extends Button

# 检查cargo是否安装的详细信息
func check_cargo_detailed() -> Dictionary:
	var result = {
		"installed": false,
		"version": "",
		"path": "",
		"error": ""
	}
	
	var cargo_command = "cargo"
	
	# Windows系统可能需要特殊处理
	if OS.get_name() == "Windows":
		# 在Windows上，如果直接调用cargo失败，尝试cargo.exe
		var test_output = []
		var test_exit_code = OS.execute(cargo_command, ["--version"], test_output)
		if test_exit_code != 0:
			cargo_command = "cargo.exe"
	
	var output = []
	var exit_code = OS.execute(cargo_command, ["--version"], output)
	
	if exit_code == 0 and output.size() > 0:
		result.installed = true
		result.version = output[0].strip_edges()
		
		# 尝试获取cargo路径
		var path_output = []
		if OS.get_name() == "Windows":
			OS.execute("where", [cargo_command], path_output)
		else:
			OS.execute("which", [cargo_command], path_output)
		
		if path_output.size() > 0:
			result.path = path_output[0].strip_edges()
		
		print("✅ Cargo 已安装")
		print("版本: ", result.version)
		print("路径: ", result.path)
	else:
		result.error = "Cargo未安装或不在系统PATH中"
		print("❌ ", result.error)
	
	return result

# 简单的cargo检查
func check_cargo_installed() -> bool:
	var output = []
	var exit_code = OS.execute("cargo", ["--version"], output)
	return exit_code == 0

# 显示错误对话框
func show_error_dialog(message: String, title: String = "系统要求"):
	var dialog = AcceptDialog.new()
	dialog.dialog_text = message
	dialog.title = title
	get_tree().current_scene.add_child(dialog)
	dialog.popup_centered()
	dialog.confirmed.connect(func(): dialog.queue_free())

# 显示成功信息对话框
func show_success_dialog(message: String, title: String = "检查结果"):
	var dialog = AcceptDialog.new()
	dialog.dialog_text = message
	dialog.title = title
	get_tree().current_scene.add_child(dialog)
	dialog.popup_centered()
	dialog.confirmed.connect(func(): dialog.queue_free())

# 异步检查cargo（避免UI卡顿）
func check_cargo_async():
	print("正在检查 Cargo 安装状态...")
	self.disabled = true  # 禁用按钮避免重复点击
	self.text = "检查中..."
	
	# 在下一帧执行检查，避免阻塞UI
	await get_tree().process_frame
	
	var cargo_info = check_cargo_detailed()
	_on_cargo_check_complete(cargo_info)

# 处理检查完成
func _on_cargo_check_complete(cargo_info: Dictionary):
	self.disabled = false
	self.text = "检查 Cargo"  # 恢复按钮文字
	
	if cargo_info.installed:
		var message = "✅ Cargo 已正确安装！\n\n版本: %s" % cargo_info.version
		if not cargo_info.path.is_empty():
			message += "\n路径: %s" % cargo_info.path
		
		show_success_dialog(message, "Cargo 检查成功")
		
		# 可以在这里触发需要cargo的操作
		emit_signal("cargo_available", cargo_info)
		
	else:
		var message = "❌ 未检测到 Cargo\n\n"
		message += "某些项目模式需要 Rust 和 Cargo 支持。\n"
		message += "请访问 https://rustup.rs/ 安装 Rust 工具链。\n\n"
		message += "安装完成后，请重启应用程序。"
		
		show_error_dialog(message, "需要安装 Cargo")
		emit_signal("cargo_unavailable")

# 当按钮被点击时执行检查
func _on_pressed():
	check_cargo_async()

# 定义信号，其他节点可以监听
signal cargo_available(cargo_info: Dictionary)
signal cargo_unavailable()

# 初始化
func _ready():
	# 连接按钮点击信号
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)
	
	# 设置按钮文字（如果没有设置的话）
	if text.is_empty():
		text = "检查 Cargo"
	
	# 可选：应用启动时自动检查一次
	# check_cargo_async()

# 为其他节点提供的公共方法
func get_cargo_status() -> Dictionary:
	"""
	供其他节点调用的方法，获取cargo状态
	返回格式: {"installed": bool, "version": String, "path": String, "error": String}
	"""
	return check_cargo_detailed()

# 静默检查（不显示对话框）
func check_cargo_silent() -> bool:
	"""
	静默检查cargo是否可用，不显示任何对话框
	适合在后台检查使用
	"""
	return check_cargo_installed()
