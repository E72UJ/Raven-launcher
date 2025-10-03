# ProjectData.gd
class_name ProjectData
extends RefCounted

# 项目基本信息
var id: String
var name: String
var path: String
var created_date: String
var modified_date: String
var engine_version: String
var project_type: String

# 可选字段
var description: String = ""
var last_opened: String = ""
var tags: Array[String] = []
var status: String = ""

# 构造函数
func _init(project_name: String = "", project_path: String = "", type: String = ""):
	if project_name != "":
		id = generate_unique_id()
		name = project_name
		path = project_path
		project_type = type
		created_date = Time.get_datetime_string_from_system()
		modified_date = created_date
		engine_version = Engine.get_version_info().string

# 生成唯一ID
func generate_unique_id() -> String:
	return str(Time.get_ticks_msec()) + "_" + str(randi())

# 创建新项目的静态方法
static func create_new_project(project_name: String, project_path: String, type: String = "Game") -> ProjectData:
	var project = ProjectData.new(project_name, project_path, type)
	return project

# 设置标签的安全方法
func set_tags(new_tags: Array) -> void:
	tags.clear()
	for tag in new_tags:
		if tag is String:
			tags.append(tag)
		else:
			tags.append(str(tag))

# 从字典创建项目数据
func from_dict(data: Dictionary) -> ProjectData:
	id = data.get("id", "")
	name = data.get("name", "")
	path = data.get("path", "")
	created_date = data.get("created_date", "")
	modified_date = data.get("modified_date", "")
	engine_version = data.get("engine_version", "")
	project_type = data.get("project_type", "")
	description = data.get("description", "")
	last_opened = data.get("last_opened", "")
	
	# 使用安全的标签设置方法
	var tags_data = data.get("tags", [])
	set_tags(tags_data)
	
	status = data.get("status", "")
	return self

# 转换为字典（用于保存）
func to_dict() -> Dictionary:
	var dict = {
		"id": id,
		"name": name,
		"path": path,
		"created_date": created_date,
		"modified_date": modified_date,
		"engine_version": engine_version,
		"project_type": project_type
	}
	
	# 只保存非空的可选字段
	if description != "":
		dict["description"] = description
	if last_opened != "":
		dict["last_opened"] = last_opened
	if tags.size() > 0:
		dict["tags"] = tags
	if status != "":
		dict["status"] = status
		
	return dict

# 获取创建日期的 DateTime 对象
func get_created_datetime() -> Dictionary:
	return Time.get_datetime_dict_from_datetime_string(created_date, false)

# 获取修改日期的 DateTime 对象
func get_modified_datetime() -> Dictionary:
	return Time.get_datetime_dict_from_datetime_string(modified_date, false)

# 更新修改时间
func update_modified_date():
	modified_date = Time.get_datetime_string_from_system()

# 添加标签
func add_tag(tag: String):
	if tag not in tags:
		tags.append(tag)
		update_modified_date()

# 移除标签
func remove_tag(tag: String):
	var index = tags.find(tag)
	if index >= 0:
		tags.remove_at(index)
		update_modified_date()

# 验证项目数据是否有效
func is_valid() -> bool:
	return name != "" and path != "" and id != ""
