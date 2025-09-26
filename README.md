# Raven-Launcher
![18414](https://www.freeimg.cn/uploads/107/3fc1bfe8a0299b3b4979a55afaa724c6.png)
Raven的启动器SDK 使用Godot 制作

Godot 版本 4.4.1

## 节点树
# Raven Launcher 节点树

## Root Node
- Type: Control
- Name: MainControl

## Children Nodes
1. **Header**
   - Type: HBoxContainer
   - Name: HeaderContainer
   - Children:
     - Label: 项目管理
     - Label: 魔法学院的秘密
     - Label: 魔法学院的秘密
     - Label: 魔法学院的秘密

2. **Content**
   - Type: VBoxContainer
   - Name: ContentContainer
   - Children:
     1. **ProjectInfo**
        - Type: GridContainer
        - Name: ProjectInfoContainer
        - Children:
          - Label: 项目路径
          - Label: Raven 版本
          - Label: 创建日期
          - Label: 最后修改
     2. **ActionButtons**
        - Type: HBoxContainer
        - Name: ActionButtonsContainer
        - Children:
          - Button: 启动项目
          - Button: 桌面测试
          - Button: 信息测试
          - Button: 构建发布

3. **Footer**
   - Type: HBoxContainer
   - Name: FooterContainer
   - Children:
     - Label: 版权所有 © 2025 Raven Studio


## 基础命名
# 方法命名
func test_on_desktop():         # 桌面测试
func edit_script():             # 编辑脚本
func test_project():            # 项目测试
func open_project_folder():     # 打开项目文件夹
func build_release():           # 构建发布版本

# 按钮节点命名
@onready var desktop_test_button = $DesktopTestButton
@onready var edit_script_button = $EditScriptButton
@onready var project_test_button = $ProjectTestButton
@onready var open_folder_button = $OpenFolderButton
@onready var build_release_button = $BuildReleaseButton