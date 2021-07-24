extends Control

signal scale_changed(bodypart)

var bodypart = null
var bodyparent = null
var bodychild = null
var HUD_active = true
onready var posXBox = get_node("Bodypart/VBoxContainer2/Horizontal/SpinBox")
onready var posYBox = get_node("Bodypart/VBoxContainer2/Horizontal/SpinBox2")
onready var rotateBox = get_node("Bodypart/VBoxContainer2/Horizontal3/SpinBox2")
onready var scaleXBox = get_node("Bodypart/VBoxContainer2/Horizontal2/SpinBox2")
onready var scaleYBox = get_node("Bodypart/VBoxContainer2/Horizontal2/SpinBox")
onready var zindexBox = get_node("Bodypart/VBoxContainer2/Horizontal4/SpinBox2")


func _process(delta):
	if bodypart != null:
		if HUD_active == true: #Affecting the body when changing values in the HUD
			#Position
			var distance = bodyparent.get_child(0).position - bodypart.position
			bodyparent.position.x = posYBox.value
			bodyparent.position.y = posXBox.value
			#Rotation
			bodyparent.global_rotation_degrees = rotateBox.value
			#Scale
			if bodypart.scale.x != scaleXBox.value:
				bodypart.scale.x = scaleXBox.value
				bodypart.get_parent().get_child(1).rect_scale.x = scaleXBox.value
				_on_scaleX_value_changed()
			if bodypart.scale.y != scaleYBox.value:
				bodypart.scale.y = scaleYBox.value
				bodypart.get_parent().get_child(1).rect_scale.y = scaleYBox.value
				_on_scaleY_value_changed()
			#Z index
			bodyparent.z_index = zindexBox.value
		else: #Set values in the HUD when clicking on the body
			#Position
			posYBox.value = bodyparent.position.x
			posXBox.value = bodyparent.position.y
			#Rotation
			rotateBox.value = bodyparent.global_rotation_degrees
			#Scale
			scaleXBox.value = bodypart.scale.x
			scaleYBox.value = bodypart.scale.y

func _on_body_bodypart_clicked(chosenBodypart):
	$Bodypart.visible = true # Showing the bodypart menu
	$"Character menu".visible = false # Hide Character menu
	bodypart = chosenBodypart
	bodyparent = bodypart.get_parent()
	# Set the top title to bodypart's name
	get_node("Bodypart/VBoxContainer2/Name").text = chosenBodypart.get_parent().get_child(1).name
	posYBox.value = bodyparent.position.x
	posXBox.value = bodyparent.position.y
	rotateBox.value = bodypart.get_parent().global_rotation_degrees
	scaleXBox.value = bodypart.scale.x
	scaleYBox.value = bodypart.scale.y
	zindexBox.value = bodyparent.z_index

func _on_scaleY_value_changed():
#	bodypart.position.x = bodypart.texture.get_height()
	bodypart.position.x = (bodypart.texture.get_height() * bodypart.scale.y)/2
#	bodypart.position.x *= bodypart.get_parent().rect_scale.y
	var button = bodypart.get_parent().get_child(3)
	emit_signal("scale_changed", button)


func _on_scaleX_value_changed():
	var bodyButton = bodypart.get_parent().get_child(1)
	bodyButton.rect_position.y = (bodyButton.rect_size.x * bodyButton.rect_scale.x)/2
#	bodypart.position.y = (bodypart.texture.get_height() * bodypart.scale.y)/2


func _on_voidClick():
	$Bodypart.visible = false
	$"Character menu".visible = true
