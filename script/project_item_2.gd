extends Button

var selfid = "vn_002"
@onready var ProjectTitle = $"../../Right/ProjectTitle"  # 你的 left 节点
@onready var ProjectPath = $"../../Right/ProjectPath"
@onready var ProjectTime = $"../../Right/ProjectTime"
@onready var ProjectVer = $"../../Right/ProjectVer"
@onready var LastModified = $"../../Right/LastModified"
@onready var pm: ProjectManager = ProjectManager.new()
func _on_pressed() -> void:
	var name = pm.get_field_by_id(selfid, "name")
	var path = pm.get_field_by_id(selfid, "path")
	var created_date = pm.get_field_by_id(selfid, "created_date")
	var engine_version = pm.get_field_by_id(selfid, "engine_version")
	var last_opened = pm.get_field_by_id(selfid, "last_opened")
	ProjectTitle.text = name
	ProjectPath.text = path
	ProjectTime.text = created_date
	ProjectVer.text = engine_version
	LastModified.text = last_opened
	pass # Replace with function body.
