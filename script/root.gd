extends Node2D


@onready var left = $Left/ProjectItem  # 你的 left 节点
@onready var left2 = $Left/ProjectItem2  # 你的 left 节点
@onready var left3 = $Left/ProjectItem3 # 你的 left 节点
@onready var pm: ProjectManager = ProjectManager.new()
func _on_ready() -> void:
	left2.get_node("Projectname").text = "项目2222"
	#pm.edit_project_by_id("vn_001", {
		#"name": "更名测试",
		#"path": "/new/path/to/project"
	#})
	var test_id = "vn_001"
	var test_id2 = "vn_002"
	var test_id3 = "vn_003"
	var name1 = pm.get_field_by_id(test_id, "name")
	var name2 = pm.get_field_by_id(test_id2, "name")
	var name3 = pm.get_field_by_id(test_id3, "name")
	left.get_node("Projectname").text = name1
	left2.get_node("Projectname").text = name2
	left3.get_node("Projectname").text = name3
#	三个不同的状态
	var sta1 = pm.get_field_by_id(test_id, "status")
	var sta2 = pm.get_field_by_id(test_id2, "status")
	var sta3 = pm.get_field_by_id(test_id3, "status")
	
	if sta1 == "show":
		left.show()
	else:
		left.hide()
	if sta2 == "show":
		left2.show()
	else:
		left2.hide()
	if sta3 == "show":
		left3.show()
	else:
		left3.hide()

	pm.print_all()
