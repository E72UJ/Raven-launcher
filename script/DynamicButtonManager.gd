# DynamicButtonManager.gd
class_name DynamicButtonManager
extends RefCounted

signal button_pressed(button_data: Dictionary, button_index: int)

var parent_node: Node
var button_list: Array[Button] = []
var button_data_list: Array[Dictionary] = []

func _init(target_node: Node):
	parent_node = target_node

# 添加单个按钮
func add_button(text: String, data: Dictionary = {}) -> Button:
	if not parent_node:
		push_error("父节点无效")
		return null
	
	var button = Button.new()
	button.text = text
	
	# 设置按钮基本属性
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(0, 40)  # 设置最小高度
	
	# 存储按钮数据
	var button_index = button_list.size()
	button_data_list.append(data)
	button_list.append(button)
	
	# 连接信号
	button.pressed.connect(_on_button_pressed.bind(button_index))
	
	# 安全添加到父节点
	if parent_node.has_method("add_child"):
		parent_node.add_child(button)
	else:
		push_error("父节点不支持添加子节点")
		return null
	
	return button

# 在指定位置插入按钮
func insert_button(index: int, text: String, data: Dictionary = {}) -> Button:
	if not parent_node:
		push_error("父节点无效")
		return null
	
	var button = Button.new()
	button.text = text
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(0, 40)
	
	# 在指定位置插入数据
	var button_index = clamp(index, 0, button_list.size())
	button_data_list.insert(button_index, data)
	button_list.insert(button_index, button)
	
	# 连接信号
	button.pressed.connect(_on_button_pressed.bind(button_index))
	
	# 添加到父节点
	parent_node.add_child(button)
	
	# 移动到指定位置
	parent_node.move_child(button, button_index)
	
	# 重新绑定所有按钮的信号（因为索引可能变化了）
	_rebind_button_signals()
	
	return button

# 批量添加按钮
func add_buttons(button_configs: Array) -> Array[Button]:
	var added_buttons: Array[Button] = []
	
	for config in button_configs:
		var text = config.get("text", "按钮")
		var data = config.get("data", {})
		var button = add_button(text, data)
		if button:
			added_buttons.append(button)
	
	return added_buttons

# 移除指定索引的按钮
func remove_button(index: int):
	if index >= 0 and index < button_list.size():
		var button = button_list[index]
		
		# 从父节点移除
		if button and button.get_parent():
			button.get_parent().remove_child(button)
		
		# 释放按钮
		if button:
			button.queue_free()
		
		# 从列表中移除
		button_list.remove_at(index)
		button_data_list.remove_at(index)
		
		# 重新绑定剩余按钮的索引
		_rebind_button_signals()

# 移除所有按钮
func clear_buttons():
	for button in button_list:
		if button and button.get_parent():
			button.get_parent().remove_child(button)
		if button:
			button.queue_free()
	
	button_list.clear()
	button_data_list.clear()

# 安全地重新排列按钮顺序
func reorder_buttons():
	if not parent_node:
		return
	
	for i in range(button_list.size()):
		var button = button_list[i]
		if button and button.get_parent() == parent_node:
			parent_node.move_child(button, i)

# 获取按钮数量
func get_button_count() -> int:
	return button_list.size()

# 获取指定按钮
func get_button(index: int) -> Button:
	if index >= 0 and index < button_list.size():
		return button_list[index]
	return null

# 获取指定按钮的数据
func get_button_data(index: int) -> Dictionary:
	if index >= 0 and index < button_data_list.size():
		return button_data_list[index]
	return {}

# 更新按钮文本
func update_button_text(index: int, new_text: String):
	var button = get_button(index)
	if button:
		button.text = new_text

# 更新按钮数据
func update_button_data(index: int, new_data: Dictionary):
	if index >= 0 and index < button_data_list.size():
		button_data_list[index] = new_data

# 设置按钮样式
func set_button_style(index: int, style_properties: Dictionary):
	var button = get_button(index)
	if not button:
		return
	
	for property in style_properties:
		var value = style_properties[property]
		match property:
			"modulate":
				button.modulate = value
			"disabled":
				button.disabled = value
			"tooltip_text":
				button.tooltip_text = value
			"custom_minimum_size":
				button.custom_minimum_size = value
			"size_flags_horizontal":
				button.size_flags_horizontal = value
			"size_flags_vertical":
				button.size_flags_vertical = value

# 高亮指定按钮
func highlight_button(index: int, highlight_color: Color = Color(1.2, 1.2, 1.2)):
	# 重置所有按钮
	for button in button_list:
		if button:
			button.modulate = Color.WHITE
	
	# 高亮指定按钮
	var button = get_button(index)
	if button:
		button.modulate = highlight_color

# 查找按钮索引（通过数据）
func find_button_by_data(search_key: String, search_value) -> int:
	for i in range(button_data_list.size()):
		var data = button_data_list[i]
		if data.has(search_key) and data[search_key] == search_value:
			return i
	return -1

# 内部方法：按钮点击回调
func _on_button_pressed(button_index: int):
	var data = get_button_data(button_index)
	button_pressed.emit(data, button_index)

# 内部方法：重新绑定按钮信号
func _rebind_button_signals():
	for i in range(button_list.size()):
		var button = button_list[i]
		if not button:
			continue
		
		# 断开旧连接
		if button.pressed.is_connected(_on_button_pressed):
			button.pressed.disconnect(_on_button_pressed)
		
		# 连接新索引
		button.pressed.connect(_on_button_pressed.bind(i))
