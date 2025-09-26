# Raven-Launcher
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
