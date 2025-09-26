extends Button

@onready var status_label = $"../../StatusLabel"
func _on_pressed() -> void:
	print("执行数据")
	pass # Replace with function body.


func _on_mouse_entered() -> void:
	status_label.text = self.text
	pass # Replace with function body.
