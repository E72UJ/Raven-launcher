extends Button

@onready var project_name_text_edit = $"../form-row/projectName"
@onready var project_path_input = $"../form-row2/project_path_input"
@onready var project_version_text = $"../form-row2/project_version_text"
@onready var ProjectModeSelector = $"../form-row3/ProjectModeSelector"
@onready var Projectype = $"../form-row4/Projecttype"

# 引用 ProjectManager 实例
var project_manager: ProjectManager

func _ready():
	# 初始化 ProjectManager
	project_manager = ProjectManager.new()

func _on_pressed() -> void:
	# 验证所有必填字段
	var validation_result = validate_fields()
	if not validation_result.is_valid:
		show_error_dialog(validation_result.error_message)
		return
	
	# 如果验证通过，执行创建项目的逻辑
	create_project()

func validate_fields() -> Dictionary:
	var errors = []
	
	# 检查项目名称
	if project_name_text_edit.text.strip_edges().is_empty():
		errors.append("• 项目名称不能为空")
	elif project_name_text_edit.text.strip_edges().length() < 2:
		errors.append("• 项目名称至少需要2个字符")
	
	# 检查项目路径
	if project_path_input.text.strip_edges().is_empty():
		errors.append("• 项目路径不能为空")
	
	# 检查项目版本
	if project_version_text.text.strip_edges().is_empty():
		errors.append("• 项目版本不能为空")
	
	# 检查项目模式选择器
	if ProjectModeSelector.selected == -1:
		errors.append("• 请选择项目模式")
	
	# 检查项目类型
	if Projectype.selected == -1:
		errors.append("• 请选择项目类型")
	
	# 返回验证结果
	if errors.size() > 0:
		return {
			"is_valid": false,
			"error_message": "请修正以下问题：\n\n" + "\n".join(errors)
		}
	else:
		return {
			"is_valid": true,
			"error_message": ""
		}

func show_error_dialog(message: String):
	# 创建错误对话框
	var error_dialog = AcceptDialog.new()
	error_dialog.title = "创建项目失败"
	error_dialog.dialog_text = message
	
	# 设置对话框样式
	error_dialog.min_size = Vector2(400, 200)
	
	# 添加到场景树
	get_tree().current_scene.add_child(error_dialog)
	
	# 居中显示
	error_dialog.popup_centered()
	
	# 当对话框关闭时自动删除
	error_dialog.confirmed.connect(func(): error_dialog.queue_free())
	
	# 如果点击外部或按ESC也能关闭
	error_dialog.close_requested.connect(func(): error_dialog.queue_free())

func show_success_dialog():
	# 创建成功对话框
	var success_dialog = AcceptDialog.new()
	success_dialog.title = "项目创建成功"
	success_dialog.dialog_text = "项目已成功创建！"
	
	# 设置对话框样式
	success_dialog.min_size = Vector2(300, 150)
	
	# 添加到场景树
	get_tree().current_scene.add_child(success_dialog)
	
	# 居中显示
	success_dialog.popup_centered()
	
	# 当对话框关闭时自动删除
	success_dialog.confirmed.connect(func(): success_dialog.queue_free())

func create_project():
	# 获取所有字段的值
	var project_name = project_name_text_edit.text.strip_edges()
	var project_path = project_path_input.text.strip_edges()
	var project_version = project_version_text.text.strip_edges()
	var project_mode = ProjectModeSelector.get_item_text(ProjectModeSelector.selected)
	var project_type = Projectype.get_item_text(Projectype.selected)
	
	print("创建项目:")
	print("  名称: ", project_name)
	print("  路径: ", project_path)
	print("  版本: ", project_version)
	print("  模式: ", project_mode)
	print("  类型: ", project_type)
	
	# 模拟项目创建过程
	var success = perform_project_creation(project_name, project_path, project_version, project_mode, project_type)
	
	if success:
		show_success_dialog()
		# 可以在这里清空表单或执行其他操作
		clear_form()
	else:
		show_error_dialog("项目创建过程中发生错误，请检查路径权限和磁盘空间。")

func find_available_slot() -> String:
	# 按顺序检查槽位，找到第一个 status 为 "hide" 的槽位
	var slot_ids = ["vn_002", "vn_003"]  # 按你的需求，vn_002 优先，然后是 vn_003
	
	for slot_id in slot_ids:
		var project = project_manager.find_by_id(slot_id)
		if project != null and project.get("status") == "hide":
			return slot_id
	
	return ""  # 没有可用槽位

func perform_project_creation(name: String, path: String, version: String, mode: String, type: String) -> bool:
	# 实际的项目创建逻辑
	# 检查路径是否存在
	if not DirAccess.dir_exists_absolute(path):
		return false
	
	# 创建项目文件夹
	var full_project_path = path + "/" + name
	var dir = DirAccess.open(path)
	if dir.make_dir(name) != OK:
		if not DirAccess.dir_exists_absolute(full_project_path):
			return false
	create_structure_from_external_zip(path + "/assets", get_app_bundle_path() + "/basic.zip")
	create_structure_from_external_zip(path, get_app_bundle_path() + "/raven.zip")  # 可能覆盖上面的文件
	# 这里可以添加更多项目创建逻辑

	
	# 找到可用的槽位并创建项目
	var available_slot = find_available_slot()
	if available_slot.is_empty():
		print("没有可用的槽位来创建项目")
		return false
	
	# 更新槽位内容并将状态设为 "show"
	var success = project_manager.edit_project_by_id(available_slot, {
		"name": name,
		"path": path,
		"project_type": type,
		"tags": [mode, version],
		"status": "show"  # 关键：设置状态为 "show" 表示已创建
	})
	
	if success:
		print("项目创建成功，使用槽位: ", available_slot)
	else:
		print("更新槽位失败: ", available_slot)
		return false
	
	return true

func clear_form():
	# 清空所有表单字段
	project_name_text_edit.text = ""
	project_path_input.text = ""
	project_version_text.text = ""
	ProjectModeSelector.selected = -1
	Projectype.selected = -1



func create_structure_from_external_zip(base_path: String, zip_path: String) -> bool:
	print("开始从外部ZIP模板创建项目结构...")
	print("ZIP路径: ", zip_path)
	print("目标路径: ", base_path)
	
	# 检查ZIP文件是否存在（支持绝对路径）
	if not FileAccess.file_exists(zip_path):
		print("❌ ZIP文件不存在: ", zip_path)
		return false
	
	# 确保目标目录存在
	var target_dir = DirAccess.open(base_path)
	if target_dir == null:
		# 尝试创建目标目录
		var parent_dir = DirAccess.open(base_path.get_base_dir())
		if parent_dir == null:
			# 如果是绝对路径，直接创建
			DirAccess.make_dir_recursive_absolute(base_path)
			target_dir = DirAccess.open(base_path)
		else:
			parent_dir.make_dir_recursive(base_path)
			target_dir = DirAccess.open(base_path)
		
		if target_dir == null:
			print("❌ 无法创建目标目录: ", base_path)
			return false
	
	# 打开ZIP文件
	var zip_reader = ZIPReader.new()
	var error = zip_reader.open(zip_path)
	if error != OK:
		print("❌ 无法打开ZIP文件: ", error_string(error))
		return false
	
	print("📦 ZIP文件打开成功")
	
	# 获取ZIP中的所有文件
	var files = zip_reader.get_files()
	print("📁 ZIP中包含 ", files.size(), " 个文件")
	
	var success_count = 0
	var total_files = files.size()
	
	# 解压每个文件
	for file_path in files:
		# 跳过.import文件
		if file_path.ends_with(".import"):
			continue
		
		# 跳过目录条目（通常以/结尾）
		if file_path.ends_with("/"):
			continue
		
		var target_file_path = base_path.path_join(file_path)
		
		if _extract_file_from_zip(zip_reader, file_path, target_file_path):
			print("  ✓ 解压: ", file_path)
			success_count += 1
		else:
			print("  ❌ 解压失败: ", file_path)
	
	zip_reader.close()
	
	print("解压完成: ", success_count, " 个文件")
	
	if success_count > 0:
		print("✅ 项目结构创建完成!")
		return true
	else:
		print("❌ 没有文件被解压")
		return false

# 从ZIP中解压单个文件（改进版）
func _extract_file_from_zip(zip_reader: ZIPReader, zip_file_path: String, target_path: String) -> bool:
	# 确保目标文件的目录存在
	var target_dir = target_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(target_dir):
		var error = DirAccess.make_dir_recursive_absolute(target_dir)
		if error != OK:
			print("    错误: 无法创建目录: ", target_dir, " (", error_string(error), ")")
			return false
	
	# 从ZIP读取文件内容
	var file_data = zip_reader.read_file(zip_file_path)
	if file_data.is_empty():
		print("    警告: ZIP中的文件为空或读取失败: ", zip_file_path)
		# 对于空文件，仍然创建它
	
	# 写入目标文件
	var target_file = FileAccess.open(target_path, FileAccess.WRITE)
	if target_file == null:
		print("    错误: 无法创建目标文件: ", target_path)
		return false
	
	target_file.store_buffer(file_data)
	target_file.close()
	
	return true
	
func get_app_bundle_path():
	var exe_path = OS.get_executable_path()
	
	# 检查路径是否有效
	if exe_path.is_empty():
		print("警告: 无法获取可执行文件路径，使用用户数据目录")
		return OS.get_user_data_dir()
	
	var exe_dir = exe_path.get_base_dir()
	var os_name = OS.get_name()
	
	print("检测到操作系统: ", os_name)
	print("可执行文件路径: ", exe_path)
	print("可执行文件目录: ", exe_dir)
	
	var result_path = ""
	
	match os_name:
		"macOS":
			if exe_dir.ends_with("/Contents/MacOS"):
				result_path = exe_dir.get_base_dir().get_base_dir().get_base_dir()
				print("macOS .app 包父目录: ", result_path)
			else:
				result_path = exe_dir
				print("macOS 非 .app 包模式: ", result_path)
		
		"iOS":
			if exe_dir.find(".app/") != -1:
				var app_index = exe_dir.find(".app/")
				var app_path = exe_dir.substr(0, app_index + 4)
				result_path = app_path.get_base_dir()
				print("iOS .app 包父目录: ", result_path)
			else:
				result_path = exe_dir
		
		"Android":
			result_path = OS.get_user_data_dir()
			print("Android 用户数据目录: ", result_path)
		
		"HTML5":
			result_path = "."
			print("Web 平台使用当前目录")
		
		_:  # Windows, Linux 等
			result_path = exe_dir
			print("默认平台路径: ", result_path)
	
	# 确保返回值不为空
	if result_path.is_empty():
		result_path = OS.get_user_data_dir()
		print("使用备用路径: ", result_path)
	
	return result_path
