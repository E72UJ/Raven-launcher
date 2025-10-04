extends Button


func _on_pressed() -> void:
	var is_pressed = self.button_pressed
	var first_child = self.get_child(0).text
	
	print(is_pressed)
	print(first_child)
	
	pass # Replace with function body.
