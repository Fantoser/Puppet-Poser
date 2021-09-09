extends Area2D

var is_mouse_over = false
var clicked = false
var is_held = false


signal button_pressed(pressed)

func _on_button_mouse_entered():
	is_mouse_over = true

func _on_button_mouse_exited():
	is_mouse_over = false

func _process(delta):
	if Input.is_action_just_released("mouseLeft"):
		if is_held == true:
			is_held = false
			emit_signal("button_pressed", false)

func _unhandled_input(event):
	if is_mouse_over:
		if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
			clicked = event.pressed
			if clicked == true:
				is_held = true
				emit_signal("button_pressed", clicked)
			get_tree().set_input_as_handled()
