extends Node2D

var project_manager: ProjectManager
func _on_ready() -> void:
	project_manager = ProjectManager.new()
	add_sample_projects(project_manager)
	if project_manager.load_projects():
		print("项目配置加载成功")
		display_projects()
	else:
		print("项目配置加载失败，创建新配置")
		create_sample_projects()
	pass # Replace with function body.
	



func display_projects():
	print("\n=== 项目列表 ===")
	for i in range(project_manager.projects.size()):
		var project = project_manager.projects[i]
		print("%d. %s (%s) - %s" % [i + 1, project.name, project.project_type, project.status])
		print("   路径: %s" % project.path)
		print("   引擎版本: %s" % project.engine_version)
		if project.tags.size() > 0:
			print("   标签: %s" % ", ".join(project.tags))
		print("")

func create_sample_projects():
	# 创建示例项目
	var project1 = ProjectData.new()
	project1.id = "proj_001"
	project1.name = "我的第一个游戏"
	project1.path = "C:/Projects/MyFirstGame"
	project1.created_date = "2024-03-15T10:30:00Z"
	project1.modified_date = "2024-10-02T16:45:30Z"
	project1.engine_version = "4.2.1"
	project1.project_type = "2D Game"
	project1.description = "一个简单的2D平台游戏"
	project1.tags = ["2d", "platform", "beginner"]
	project1.status = "active"
	
	project_manager.add_project(project1)
	
	# 保存配置
	project_manager.save_projects()
	print("示例项目已创建")

# 搜索项目的示例函数
func search_projects_example():
	# 按名称搜索
	var search_results = project_manager.find_projects_by_name("游戏")
	print("搜索'游戏'的结果: ", search_results.size(), " 个项目")
	
	# 按类型筛选
	var game_projects = project_manager.filter_by_type("2D Game")
	print("2D游戏项目: ", game_projects.size(), " 个")
	
	# 按标签筛选
	var platform_games = project_manager.filter_by_tag("platform")
	print("平台游戏: ", platform_games.size(), " 个")
	
	# 按状态筛选
	var active_projects = project_manager.filter_by_status("active")
	print("活跃项目: ", active_projects.size(), " 个")

# 更新项目信息的示例
func update_project_example():
	var project = project_manager.find_project_by_id("proj_001")
	if project:
		project.description = "更新后的描述"
		project.modified_date = Time.get_datetime_string_from_system()
		project_manager.save_projects()
		print("项目信息已更新")


func add_sample_projects(manager: ProjectManager):
	# 方式1：使用 add_tag 方法
	
	# 方式3：逐个添加标签
	var project3 = ProjectData.new()
	project3.id = project3.generate_unique_id()
	project3.name = "拼图游戏"
	project3.path = "res://projects/puzzle_game/"
	project3.project_type = "Puzzle"
	project3.description = "有趣的拼图解谜游戏"
	project3.created_date = Time.get_datetime_string_from_system()
	project3.modified_date = project3.created_date
	project3.engine_version = Engine.get_version_info().string
	project3.status = "原型"
	# 不要直接赋值给 tags，使用方法
	project3.add_tag("拼图")
	project3.add_tag("休闲")
	
	# 添加到管理器
	manager.add_project(project3)
	
	print("已添加 3 个项目")

	
