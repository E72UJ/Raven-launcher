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
	
	# 这里可以添加更多项目创建逻辑
	# 比如创建配置文件、初始化文件等
	
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
