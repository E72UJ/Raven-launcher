extends Node2D

@onready var project_name_text_edit = $"form-row/projectName"
@onready var submit_button = $create_button  # 假设你有一个提交按钮

var is_project_name_valid: bool = false
func _on_project_name_text_changed() -> void:
	var text_content = project_name_text_edit.text.strip_edges()
	
	# 验证规则
	var is_valid = true
	
	# 必填检查
	if text_content.is_empty():
		is_valid = false
	
	# 长度检查（比如最少3个字符）
	if text_content.length() < 3:
		is_valid = false
	
	# 更新验证状态
	is_project_name_valid = is_valid
	
	# 视觉反馈
	if is_valid:
		project_name_text_edit.modulate = Color.WHITE
	else:
		project_name_text_edit.modulate = Color(1.0, 0.8, 0.8)  # 淡红色
	
	# 更新提交按钮状态
	update_submit_button()
	pass # Replace with function body.


func update_submit_button():
	# 只有当所有字段都有效时才启用提交按钮
	submit_button.disabled = not is_project_name_valid


func _on_project_path_input_text_changed() -> void:
	var text_content = project_name_text_edit.text.strip_edges()
	
	# 验证规则
	var is_valid = true
	
	# 必填检查
	if text_content.is_empty():
		is_valid = false
	
	# 长度检查（比如最少3个字符）
	if text_content.length() < 3:
		is_valid = false
	
	# 更新验证状态
	is_project_name_valid = is_valid
	
	# 视觉反馈
	if is_valid:
		project_name_text_edit.modulate = Color.WHITE
	else:
		project_name_text_edit.modulate = Color(1.0, 0.8, 0.8)  # 淡红色
	
	# 更新提交按钮状态
	update_submit_button()
	pass # Replace with function body.
	pass # Replace with function body.
