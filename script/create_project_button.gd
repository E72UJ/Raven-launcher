extends Button

@onready var button1 = $"../../Left/ProjectItem"
@onready var button2 = $"../../Left/ProjectItem2"
@onready var button3 = $"../../Left/ProjectItem3"

var dialog_shown = false

func _on_pressed() -> void:

	
	# 检查所有按钮是否都显示
	if check_all_buttons_visible():
		show_dialog()
		return  # 阻止继续执行新建项目的逻辑
	
	# 如果不是所有按钮都显示，则正常执行新建项目
	create_new_project()

func check_all_buttons_visible() -> bool:
	# 确保按钮节点存在并且都可见
	if button1 and button2 and button3:
		return button1.visible and button2.visible and button3.visible
	return false

func create_new_project():
	# 这里放置新建项目的逻辑
	print("创建新项目...")
	get_tree().change_scene_to_file("res://New_project.tscn")

func show_dialog():
	#if dialog_shown:
		#return  # 防止重复弹出
		
	dialog_shown = true
	var dialog = AcceptDialog.new()
	dialog.title = "提示"
	dialog.dialog_text = "所有按钮都已显示，无法新建项目！"
	get_tree().current_scene.add_child(dialog)
	dialog.popup_centered()
	
	# 对话框关闭后重置标志
	dialog.close_requested.connect(func(): 
		dialog_shown = false
		dialog.queue_free()  # 清理对话框节点
	)
