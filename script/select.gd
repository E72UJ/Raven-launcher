extends Button

@onready var project_path_input = $"../project_path_input"

func _ready():
	# 确保信号连接
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)
		print("手动连接了 pressed 信号")
	else:
		print("pressed 信号已连接")

func show_directory_dialog():
	# 先检查节点是否还在场景树中
	if not is_inside_tree():
		print("错误：节点不在场景树中")
		return
	
	var fd = FileDialog.new()
	fd.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	fd.access = FileDialog.ACCESS_FILESYSTEM
	fd.title = "选择保存目录"
	fd.min_size = Vector2(800, 600)
	fd.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	
	# 将对话框添加到当前场景而不是根节点
	get_parent().add_child(fd)  # 或者使用 add_child(fd)
	fd.popup_centered()
	
	print("对话框已显示，等待用户操作...")
	
	var selected_dir = ""
	
	# 使用 await 直接等待信号
	var result = await fd.dir_selected
	if result:
		print("用户选择了目录: ", result)
		project_path_input.text = result
		selected_dir = result
	
	print("用户操作完成，清理对话框")
	fd.queue_free()
	
	print("返回结果: '", selected_dir, "'")
	return selected_dir

func _show_dialog_async():
	var save_directory = await show_directory_dialog()
	print("选择的目录: '", save_directory, "'")

func _on_pressed() -> void:
	# 直接调用，不需要 call_deferred
	_show_dialog_async()
