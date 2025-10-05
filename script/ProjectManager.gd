class_name ProjectManager
extends RefCounted

# 项目数据结构
class Project:
	var id: String
	var name: String
	var path: String
	var created_date: String
	var modified_date: String
	var engine_version: String
	var project_type: String
	var description: String
	var last_opened: String
	var tags: Array[String]
	var status: String
	
	func _init(n: String = "", p: String = "", desc: String = "", t: Array[String] = [], type: String = "Visual Novel"):
		name = n
		path = p
		description = desc
		tags = t
		project_type = type
		var current_time = Time.get_datetime_string_from_system()
		created_date = current_time
		modified_date = current_time
		last_opened = current_time
		engine_version = "Godot 4.2.1"
		status = "开发中"
		id = "vn_" + str(randi() % 1000).pad_zeros(3)
	
	func to_dict() -> Dictionary:
		return {
			"id": id,
			"name": name,
			"path": path,
			"created_date": created_date,
			"modified_date": modified_date,
			"engine_version": engine_version,
			"project_type": project_type,
			"description": description,
			"last_opened": last_opened,
			"tags": tags,
			"status": status
		}
	
	func from_dict(data: Dictionary):
		id = data.get("id", "")
		name = data.get("name", "")
		path = data.get("path", "")
		created_date = data.get("created_date", "")
		modified_date = data.get("modified_date", "")
		engine_version = data.get("engine_version", "Godot 4.2.1")
		project_type = data.get("project_type", "Visual Novel")
		description = data.get("description", "")
		last_opened = data.get("last_opened", "")
		status = data.get("status", "开发中")
		
		# 处理 tags 数组类型转换
		var raw_tags = data.get("tags", [])
		tags.clear()
		if raw_tags is Array:
			for tag in raw_tags:
				if tag is String:
					tags.append(tag)
				else:
					tags.append(str(tag))

# 数据
var projects: Array[Project] = []
var file_path: String
var metadata: Dictionary = {
	"version": "2.1.0",
	"last_updated": "",
	"total_projects": 0
}

# 构造函数
var executable_dir = OS.get_executable_path().get_base_dir()
func _init(json_file: String = executable_dir + "/projects.json"):
	file_path = json_file
	load_data()

# 添加项目
func add(name: String, path: String = "", description: String = "", tags: Array[String] = [], project_type: String = "Visual Novel") -> Project:
	if name.is_empty():
		print("项目名称不能为空")
		return null
	
	# 检查重复
	for p in projects:
		if p.name == name:
			print("项目名称已存在: ", name)
			return null
	
	var project = Project.new(name, path, description, tags, project_type)
	projects.append(project)
	update_metadata()
	save_data()
	print("添加项目: ", name)
	return project

# 删除项目
func remove(name: String) -> bool:
	for i in range(projects.size()):
		if projects[i].name == name:
			projects.remove_at(i)
			update_metadata()
			save_data()
			print("删除项目: ", name)
			return true
	print("未找到项目: ", name)
	return false

# 根据ID删除项目
func remove_by_id(id: String) -> bool:
	for i in range(projects.size()):
		if projects[i].id == id:
			var name = projects[i].name
			projects.remove_at(i)
			update_metadata()
			save_data()
			print("删除项目: ", name)
			return true
	print("未找到项目ID: ", id)
	return false

# 查找项目
func find(name: String) -> Project:
	for p in projects:
		if p.name == name:
			return p
	return null

# 根据ID查找项目
func find_by_id(id: String) -> Project:
	for p in projects:
		if p.id == id:
			return p
	return null

# 获取所有项目
func get_all() -> Array[Project]:
	return projects

# 搜索项目
func search(keyword: String) -> Array[Project]:
	var results: Array[Project] = []
	var key = keyword.to_lower()
	
	for p in projects:
		if (p.name.to_lower().contains(key) or 
			p.description.to_lower().contains(key) or
			p.project_type.to_lower().contains(key) or
			p.status.to_lower().contains(key)):
			results.append(p)
	
	return results

# 按标签筛选
func filter_by_tag(tag: String) -> Array[Project]:
	var results: Array[Project] = []
	for p in projects:
		if tag in p.tags:
			results.append(p)
	return results

# 按状态筛选
func filter_by_status(status: String) -> Array[Project]:
	var results: Array[Project] = []
	for p in projects:
		if p.status == status:
			results.append(p)
	return results

# 按项目类型筛选
func filter_by_type(project_type: String) -> Array[Project]:
	var results: Array[Project] = []
	for p in projects:
		if p.project_type == project_type:
			results.append(p)
	return results

# 更新项目（保留原有方法）
func update(name: String, new_path: String = "", new_desc: String = "", new_tags: Array[String] = [], new_status: String = "") -> bool:
	var project = find(name)
	if project == null:
		print("未找到项目: ", name)
		return false
	
	if not new_path.is_empty():
		project.path = new_path
	if not new_desc.is_empty():
		project.description = new_desc
	if not new_tags.is_empty():
		project.tags = new_tags
	if not new_status.is_empty():
		project.status = new_status
	
	project.modified_date = Time.get_datetime_string_from_system()
	update_metadata()
	save_data()
	print("更新项目: ", name)
	return true

# === 新增的编辑方法 ===

# 根据名称编辑项目
func edit_project_by_name(name: String, updates: Dictionary) -> bool:
	var project = find(name)
	if project == null:
		print("未找到项目: ", name)
		return false
	
	return _apply_updates(project, updates)

# 根据ID编辑项目
func edit_project_by_id(id: String, updates: Dictionary) -> bool:
	var project = find_by_id(id)
	if project == null:
		print("未找到项目ID: ", id)
		return false
	
	return _apply_updates(project, updates)

# 根据索引编辑项目
func edit_project_by_index(index: int, updates: Dictionary) -> bool:
	if index < 0 or index >= projects.size():
		print("索引超出范围: ", index)
		return false
	
	return _apply_updates(projects[index], updates)

# 应用更新的私有方法
func _apply_updates(project: Project, updates: Dictionary) -> bool:
	var changed = false
	
	if updates.has("name") and updates["name"] != "":
		project.name = updates["name"]
		changed = true
	
	if updates.has("path"):
		project.path = updates["path"]
		changed = true
	
	if updates.has("description"):
		project.description = updates["description"]
		changed = true
	
	if updates.has("status"):
		project.status = updates["status"]
		changed = true
	
	if updates.has("engine_version"):
		project.engine_version = updates["engine_version"]
		changed = true
	
	if updates.has("project_type"):
		project.project_type = updates["project_type"]
		changed = true
	
	# 处理标签
	if updates.has("tags"):
		var new_tags = updates["tags"]
		if new_tags is Array:
			project.tags.clear()
			for tag in new_tags:
				project.tags.append(str(tag))
			changed = true
	
	# 添加标签（不替换现有标签）
	if updates.has("add_tags"):
		var add_tags = updates["add_tags"]
		if add_tags is Array:
			for tag in add_tags:
				var tag_str = str(tag)
				if tag_str not in project.tags:
					project.tags.append(tag_str)
					changed = true
	
	# 移除标签
	if updates.has("remove_tags"):
		var remove_tags = updates["remove_tags"]
		if remove_tags is Array:
			for tag in remove_tags:
				var tag_str = str(tag)
				if tag_str in project.tags:
					project.tags.erase(tag_str)
					changed = true
	
	if changed:
		project.modified_date = Time.get_datetime_string_from_system()
		update_metadata()
		save_data()
		print("已更新项目: ", project.name)
	
	return changed

# 批量编辑多个项目
func batch_edit(condition: Callable, updates: Dictionary) -> int:
	var count = 0
	for project in projects:
		if condition.call(project):
			if _apply_updates(project, updates):
				count += 1
	
	if count > 0:
		print("批量更新了 %d 个项目" % count)
	
	return count

# === 遍历方法 ===

# 基本遍历
func traverse_all_projects():
	print("=== 遍历所有项目 ===")
	for i in range(projects.size()):
		var project = projects[i]
		print("索引 %d:" % i)
		print("  ID: %s" % project.id)
		print("  名称: %s" % project.name)
		print("  状态: %s" % project.status)
		print("  标签: %s" % str(project.tags))
		print("---")

# 使用回调函数遍历
func traverse_with_callback(callback: Callable):
	for project in projects:
		callback.call(project)

# 条件遍历和筛选
func traverse_by_condition(condition: Callable) -> Array[Project]:
	var results: Array[Project] = []
	for project in projects:
		if condition.call(project):
			results.append(project)
	return results

# === 高级编辑功能 ===

# 交换两个项目的位置
func swap_projects(index1: int, index2: int) -> bool:
	if index1 < 0 or index1 >= projects.size() or index2 < 0 or index2 >= projects.size():
		print("索引超出范围")
		return false
	
	var temp = projects[index1]
	projects[index1] = projects[index2]
	projects[index2] = temp
	
	update_metadata()
	save_data()
	print("交换了项目位置: %d <-> %d" % [index1, index2])
	return true

# 排序项目
func sort_projects(sort_by: String, ascending: bool = true):
	match sort_by:
		"name":
			projects.sort_custom(func(a, b): 
				return a.name < b.name if ascending else a.name > b.name)
		"created_date":
			projects.sort_custom(func(a, b): 
				return a.created_date < b.created_date if ascending else a.created_date > b.created_date)
		"modified_date":
			projects.sort_custom(func(a, b): 
				return a.modified_date < b.modified_date if ascending else a.modified_date > b.modified_date)
		"status":
			projects.sort_custom(func(a, b): 
				return a.status < b.status if ascending else a.status > b.status)
	
	update_metadata()
	save_data()
	print("按 %s 排序完成" % sort_by)

# 复制项目
func duplicate_project(name: String, new_name: String) -> Project:
	var original = find(name)
	if original == null:
		print("未找到源项目: ", name)
		return null
	
	var duplicate = Project.new()
	duplicate.name = new_name
	duplicate.path = original.path
	duplicate.description = original.description + " (副本)"
	duplicate.tags = original.tags.duplicate()
	duplicate.project_type = original.project_type
	duplicate.engine_version = original.engine_version
	duplicate.status = "开发中"
	
	projects.append(duplicate)
	update_metadata()
	save_data()
	print("复制项目: %s -> %s" % [name, new_name])
	return duplicate

# 打开项目（更新最后打开时间）
func open_project(name: String) -> bool:
	var project = find(name)
	if project == null:
		print("未找到项目: ", name)
		return false
	
	project.last_opened = Time.get_datetime_string_from_system()
	project.modified_date = project.last_opened
	update_metadata()
	save_data()
	print("打开项目: ", name)
	return true

# 获取项目数量
func count() -> int:
	return projects.size()

# 检查项目是否存在
func exists(name: String) -> bool:
	return find(name) != null

# 更新元数据
func update_metadata():
	metadata["last_updated"] = Time.get_datetime_string_from_system()
	metadata["total_projects"] = projects.size()

# 保存到文件
func save_data() -> bool:
	var projects_data = []
	for p in projects:
		projects_data.append(p.to_dict())
	
	var data = {
		"projects": projects_data,
		"metadata": metadata
	}
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		print("无法保存文件: ", file_path)
		return false
	
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	print("已保存 ", projects.size(), " 个项目到文件")
	return true

# 从文件加载
func load_data() -> bool:
	if not FileAccess.file_exists(file_path):
		print("文件不存在，将创建新文件: ", file_path)
		return true
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		print("无法读取文件: ", file_path)
		return false
	
	var json_text = file.get_as_text()
	file.close()
	
	if json_text.is_empty():
		print("文件为空")
		return true
	
	var json = JSON.new()
	if json.parse(json_text) != OK:
		print("JSON解析失败: ", json.get_error_message())
		return false
	
	var data = json.data
	if not data is Dictionary:
		print("数据格式错误，期望Dictionary")
		return false
	
	# 加载项目数据
	var projects_data = data.get("projects", [])
	if projects_data is Array:
		projects.clear()
		for item in projects_data:
			if item is Dictionary:
				var project = Project.new()
				project.from_dict(item)
				projects.append(project)
	
	# 加载元数据
	if data.has("metadata"):
		metadata = data["metadata"]
	
	print("加载了 ", projects.size(), " 个项目")
	return true

# 清空所有项目
func clear():
	projects.clear()
	update_metadata()
	save_data()
	print("已清空所有项目")

# 导出JSON字符串
func export_json() -> String:
	var projects_data = []
	for p in projects:
		projects_data.append(p.to_dict())
	
	var data = {
		"projects": projects_data,
		"metadata": metadata
	}
	return JSON.stringify(data, "\t")

# 从JSON字符串导入
func import_json(json_string: String) -> bool:
	var json = JSON.new()
	if json.parse(json_string) != OK:
		print("JSON解析失败: ", json.get_error_message())
		return false
	
	var data = json.data
	if not data is Dictionary:
		print("数据格式错误")
		return false
	
	var projects_data = data.get("projects", [])
	if not projects_data is Array:
		print("项目数据格式错误")
		return false
	
	projects.clear()
	for item in projects_data:
		if item is Dictionary:
			var project = Project.new()
			project.from_dict(item)
			projects.append(project)
	
	if data.has("metadata"):
		metadata = data["metadata"]
	
	update_metadata()
	save_data()
	print("导入了 ", projects.size(), " 个项目")
	return true

# 获取元数据
func get_metadata() -> Dictionary:
	return metadata

# 打印所有项目
func print_all():
	print("=== 项目列表 ===")
	print("总计: ", projects.size(), " 个项目")
	for p in projects:
		print("ID: %s | 名称: %s | 状态: %s | 类型: %s" % [p.id, p.name, p.status, p.project_type])
		print("  路径: %s" % p.path)
		print("  描述: %s" % p.description)
		print("  标签: %s" % str(p.tags))
		print("  最后打开: %s" % p.last_opened)
		print("---")

# 获取统计信息
func get_statistics() -> Dictionary:
	var stats = {
		"total": projects.size(),
		"by_status": {},
		"by_type": {},
		"recent_projects": []
	}
	
	# 按状态统计
	for p in projects:
		if stats["by_status"].has(p.status):
			stats["by_status"][p.status] += 1
		else:
			stats["by_status"][p.status] = 1
	
	# 按类型统计
	for p in projects:
		if stats["by_type"].has(p.project_type):
			stats["by_type"][p.project_type] += 1
		else:
			stats["by_type"][p.project_type] = 1
	
	# 最近项目（按最后打开时间排序）
	var sorted_projects = projects.duplicate()
	sorted_projects.sort_custom(func(a, b): return a.last_opened > b.last_opened)
	
	for i in range(min(5, sorted_projects.size())):
		stats["recent_projects"].append({
			"name": sorted_projects[i].name,
			"last_opened": sorted_projects[i].last_opened
		})
	
	return stats


# === 字段获取方法 ===

# 根据ID获取特定字段
func get_field_by_id(id: String, field_name: String):
	var project = find_by_id(id)
	if project == null:
		print("未找到项目ID: ", id)
		return null
	
	# 根据字段名返回对应的值
	match field_name:
		"id":
			return project.id
		"name":
			return project.name
		"path":
			return project.path
		"description":
			return project.description
		"status":
			return project.status
		"tags":
			return project.tags
		"project_type":
			return project.project_type
		"engine_version":
			return project.engine_version
		"created_date":
			return project.created_date
		"modified_date":
			return project.modified_date
		"last_opened":
			return project.last_opened
		_:
			print("未知字段: ", field_name)
			return null

# 通过字典获取字段（更灵活的方式）
func get_field_from_dict(id: String, field_name: String):
	var project = find_by_id(id)
	if project == null:
		return null
	
	var project_dict = project.to_dict()
	return project_dict.get(field_name, null)

# 安全的字段获取（带默认值）
func get_field_safe(id: String, field_name: String, default_value = null):
	var project = find_by_id(id)
	if project == null:
		return default_value
	
	var project_dict = project.to_dict()
	if project_dict.has(field_name):
		return project_dict[field_name]
	else:
		print("字段不存在: ", field_name)
		return default_value

# 获取多个字段
func get_multiple_fields(id: String, field_names: Array[String]) -> Dictionary:
	var project = find_by_id(id)
	if project == null:
		return {}
	
	var result = {}
	var project_dict = project.to_dict()
	
	for field in field_names:
		if project_dict.has(field):
			result[field] = project_dict[field]
		else:
			result[field] = null
			print("警告：字段不存在 - ", field)
	
	return result

# 获取所有字段
func get_all_fields(id: String) -> Dictionary:
	var project = find_by_id(id)
	if project == null:
		return {}
	
	return project.to_dict()

# 获取指定类型的字段
func get_fields_by_type(id: String, field_type: String) -> Dictionary:
	var project = find_by_id(id)
	if project == null:
		return {}
	
	var result = {}
	var project_dict = project.to_dict()
	
	for key in project_dict:
		var value = project_dict[key]
		match field_type:
			"string":
				if value is String:
					result[key] = value
			"array":
				if value is Array:
					result[key] = value
			"number":
				if value is int or value is float:
					result[key] = value
			"date":
				if key.contains("date") or key.contains("opened"):
					result[key] = value
	
	return result

# === 特殊字段处理 ===

# 获取标签字段（特殊处理）
func get_tags_by_id(id: String) -> Array[String]:
	var tags = get_field_by_id(id, "tags")
	if tags is Array:
		var string_tags: Array[String] = []
		for tag in tags:
			string_tags.append(str(tag))
		return string_tags
	return []

# 获取时间字段（格式化）
func get_formatted_date(id: String, date_field: String) -> String:
	var date_value = get_field_by_id(id, date_field)
	if date_value is String and not date_value.is_empty():
		return date_value
	return "未知时间"

# 获取路径字段（验证存在性）
func get_validated_path(id: String) -> Dictionary:
	var path = get_field_by_id(id, "path")
	return {
		"path": path,
		"exists": FileAccess.file_exists(str(path)) if path else false,
		"is_directory": DirAccess.dir_exists_absolute(str(path)) if path else false
	}

# 获取状态字段（带颜色信息）
func get_status_info(id: String) -> Dictionary:
	var status = get_field_by_id(id, "status")
	var color = Color.WHITE
	
	match str(status):
		"开发中":
			color = Color.YELLOW
		"已完成":
			color = Color.GREEN
		"暂停":
			color = Color.ORANGE
		"取消":
			color = Color.RED
		_:
			color = Color.GRAY
	
	return {
		"status": status,
		"color": color,
		"display_name": str(status)
	}

# === 字段操作辅助方法 ===

# 字段是否存在
func has_field(id: String, field_name: String) -> bool:
	var project = find_by_id(id)
	if project == null:
		return false
	
	var project_dict = project.to_dict()
	return project_dict.has(field_name)

# 字段是否为空
func is_field_empty(id: String, field_name: String) -> bool:
	var value = get_field_by_id(id, field_name)
	if value == null:
		return true
	
	if value is String:
		return value.is_empty()
	elif value is Array:
		return value.is_empty()
	elif value is Dictionary:
		return value.is_empty()
	else:
		return false

# 获取字段类型
func get_field_type(id: String, field_name: String) -> String:
	var value = get_field_by_id(id, field_name)
	if value == null:
		return "null"
	elif value is String:
		return "String"
	elif value is Array:
		return "Array"
	elif value is Dictionary:
		return "Dictionary"
	elif value is int:
		return "int"
	elif value is float:
		return "float"
	elif value is bool:
		return "bool"
	else:
		return "unknown"

# 搜索包含特定值的字段
func find_fields_with_value(id: String, search_value) -> Array[String]:
	var project = find_by_id(id)
	if project == null:
		return []
	
	var matching_fields: Array[String] = []
	var project_dict = project.to_dict()
	
	for field_name in project_dict:
		var field_value = project_dict[field_name]
		
		if field_value == search_value:
			matching_fields.append(field_name)
		elif field_value is String and search_value is String:
			if field_value.to_lower().contains(search_value.to_lower()):
				matching_fields.append(field_name)
		elif field_value is Array and search_value in field_value:
			matching_fields.append(field_name)
	
	return matching_fields

# 比较两个项目的字段
func compare_field(id1: String, id2: String, field_name: String) -> Dictionary:
	var value1 = get_field_by_id(id1, field_name)
	var value2 = get_field_by_id(id2, field_name)
	
	return {
		"field": field_name,
		"project1": {"id": id1, "value": value1},
		"project2": {"id": id2, "value": value2},
		"equal": value1 == value2,
		"both_exist": value1 != null and value2 != null
	}

# 根据名称获取字段（向后兼容）
func get_field_by_name(project_name: String, field_name: String):
	var project = find(project_name)
	if project == null:
		print("未找到项目: ", project_name)
		return null
	
	return get_field_by_id(project.id, field_name)

# 批量获取多个项目的特定字段
func get_field_for_all_projects(field_name: String) -> Dictionary:
	var result = {}
	for project in projects:
		result[project.id] = get_field_by_id(project.id, field_name)
	return result

# 获取字段的统计信息
func get_field_statistics(field_name: String) -> Dictionary:
	var stats = {
		"total_projects": projects.size(),
		"non_null_count": 0,
		"null_count": 0,
		"unique_values": [],
		"value_counts": {}
	}
	
	for project in projects:
		var value = get_field_by_id(project.id, field_name)
		
		if value == null:
			stats["null_count"] += 1
		else:
			stats["non_null_count"] += 1
			
			var value_str = str(value)
			if value_str not in stats["unique_values"]:
				stats["unique_values"].append(value_str)
			
			if stats["value_counts"].has(value_str):
				stats["value_counts"][value_str] += 1
			else:
				stats["value_counts"][value_str] = 1
	
	return stats

# === 测试方法 ===

# 测试字段操作
func test_field_operations():
	print("=== 字段操作测试 ===")
	
	if projects.is_empty():
		print("没有项目可测试，请先添加一些项目")
		return
	
	var test_project = projects[0]
	var test_id = test_project.id
	
	print("测试项目ID: ", test_id)
	print("测试项目名称: ", test_project.name)
	
	# 测试获取各种字段
	print("\n--- 字段获取测试 ---")
	print("项目名称: ", get_field_by_id(test_id, "name"))
	print("项目路径: ", get_field_by_id(test_id, "path"))
	print("项目描述: ", get_field_by_id(test_id, "description"))
	print("项目标签: ", get_field_by_id(test_id, "tags"))
	print("项目状态: ", get_field_by_id(test_id, "status"))
	
	# 测试字段存在性
	print("\n--- 字段存在性测试 ---")
	print("name字段存在: ", has_field(test_id, "name"))
	print("unknown字段存在: ", has_field(test_id, "unknown"))
	
	# 测试字段类型
	print("\n--- 字段类型测试 ---")
	print("name字段类型: ", get_field_type(test_id, "name"))
	print("tags字段类型: ", get_field_type(test_id, "tags"))
	
	# 测试多字段获取
	print("\n--- 多字段获取测试 ---")
	var multiple = get_multiple_fields(test_id, ["name", "status", "tags", "project_type"])
	for key in multiple:
		print("%s: %s" % [key, multiple[key]])
	
	# 测试特殊字段处理
	print("\n--- 特殊字段处理测试 ---")
	var tags = get_tags_by_id(test_id)
	var status_info = get_status_info(test_id)
	var path_info = get_validated_path(test_id)
	
	print("格式化标签: ", tags)
	print("状态信息: ", status_info)
	print("路径验证: ", path_info)
	
	# 测试字段统计
	print("\n--- 字段统计测试 ---")
	var status_stats = get_field_statistics("status")
	print("状态字段统计: ", status_stats)
