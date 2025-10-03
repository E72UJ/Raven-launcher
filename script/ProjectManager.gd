# ProjectManager.gd
class_name ProjectManager
extends RefCounted

# 项目列表
var projects: Array[ProjectData] = []
var metadata: Dictionary = {}

# 配置文件路径
var config_file_path: String = "res://asstes/projects.json"

# 从文件加载项目配置
func load_projects() -> bool:
	if not FileAccess.file_exists(config_file_path):
		print("配置文件不存在: ", config_file_path)
		return false
	
	var file = FileAccess.open(config_file_path, FileAccess.READ)
	if file == null:
		print("无法打开配置文件: ", config_file_path)
		return false
	
	var json_text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	
	if parse_result != OK:
		print("JSON 解析失败: ", json.get_error_message())
		return false
	
	var data = json.data
	if typeof(data) != TYPE_DICTIONARY:
		print("JSON 格式错误：根节点不是字典")
		return false
	
	# 加载项目列表
	if data.has("projects") and data["projects"] is Array:
		projects.clear()
		for project_dict in data["projects"]:
			if project_dict is Dictionary:
				var project_data = ProjectData.new()
				project_data.from_dict(project_dict)
				projects.append(project_data)
	
	# 加载元数据
	if data.has("metadata") and data["metadata"] is Dictionary:
		metadata = data["metadata"]
	
	print("成功加载 ", projects.size(), " 个项目")
	return true

# 保存项目配置到文件
func save_projects() -> bool:
	var data = {
		"projects": [],
		"metadata": {
			"version": "1.0.0",
			"last_updated": Time.get_datetime_string_from_system(),
			"total_projects": projects.size()
		}
	}
	
	# 转换项目数据
	for project in projects:
		data["projects"].append(project.to_dict())
	
	var json_string = JSON.stringify(data, "\t")
	
	var file = FileAccess.open(config_file_path, FileAccess.WRITE)
	if file == null:
		print("无法创建配置文件: ", config_file_path)
		return false
	
	file.store_string(json_string)
	file.close()
	
	print("配置文件已保存: ", config_file_path)
	return true

# 添加新项目
func add_project(project_data: ProjectData) -> void:
	projects.append(project_data)
	update_metadata()

# 删除项目
func remove_project(project_id: String) -> bool:
	for i in range(projects.size()):
		if projects[i].id == project_id:
			projects.remove_at(i)
			update_metadata()
			return true
	return false

# 根据ID查找项目
func find_project_by_id(project_id: String) -> ProjectData:
	for project in projects:
		if project.id == project_id:
			return project
	return null

# 根据名称查找项目
func find_projects_by_name(name: String) -> Array[ProjectData]:
	var result: Array[ProjectData] = []
	for project in projects:
		if project.name.to_lower().contains(name.to_lower()):
			result.append(project)
	return result

# 根据类型筛选项目
func filter_by_type(project_type: String) -> Array[ProjectData]:
	var result: Array[ProjectData] = []
	for project in projects:
		if project.project_type == project_type:
			result.append(project)
	return result

# 根据状态筛选项目
func filter_by_status(status: String) -> Array[ProjectData]:
	var result: Array[ProjectData] = []
	for project in projects:
		if project.status == status:
			result.append(project)
	return result

# 根据标签筛选项目
func filter_by_tag(tag: String) -> Array[ProjectData]:
	var result: Array[ProjectData] = []
	for project in projects:
		if tag in project.tags:
			result.append(project)
	return result

# 更新项目的最后打开时间
func update_last_opened(project_id: String) -> void:
	var project = find_project_by_id(project_id)
	if project:
		project.last_opened = Time.get_datetime_string_from_system()
		project.modified_date = project.last_opened

# 更新元数据
func update_metadata() -> void:
	metadata = {
		"version": "1.0.0",
		"last_updated": Time.get_datetime_string_from_system(),
		"total_projects": projects.size()
	}

# 获取所有项目类型
func get_all_project_types() -> Array[String]:
	var types: Array[String] = []
	for project in projects:
		if project.project_type not in types:
			types.append(project.project_type)
	return types

# 获取所有状态
func get_all_statuses() -> Array[String]:
	var statuses: Array[String] = []
	for project in projects:
		if project.status != "" and project.status not in statuses:
			statuses.append(project.status)
	return statuses

# 获取所有标签
func get_all_tags() -> Array[String]:
	var all_tags: Array[String] = []
	for project in projects:
		for tag in project.tags:
			if tag not in all_tags:
				all_tags.append(tag)
	return all_tags
