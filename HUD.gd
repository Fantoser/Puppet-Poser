extends Control


var bodypart = null
var bodyparent = null
var bodychild = null
var HUD_active = true
onready var posXBox = get_node("Bodypart/VBoxContainer2/Horizontal/SpinBox")
onready var posYBox = get_node("Bodypart/VBoxContainer2/Horizontal/SpinBox2")
onready var rotateBox = get_node("Bodypart/VBoxContainer2/Horizontal3/SpinBox2")
onready var zindexBox = get_node("Bodypart/VBoxContainer2/Horizontal4/SpinBox2")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if bodypart != null:
		if HUD_active == true:
			#Position
			var distance = bodyparent.get_child(0).position - bodypart.position
			bodyparent.position.x = posXBox.value
			bodyparent.position.y = posYBox.value
			#Rotation
			bodyparent.global_rotation_degrees = rotateBox.value
			#Z index
			bodyparent.z_index = zindexBox.value
		else:
			#Position
			posXBox.value = bodyparent.position.x
			posYBox.value = bodyparent.position.y
			#Rotation
			rotateBox.value = bodyparent.global_rotation_degrees

func _on_body_bodypart_clicked(chosenBodypart):
	bodypart = chosenBodypart
	bodyparent = bodypart.get_parent().get_parent()
	bodychild = bodypart.get_child(0)
	get_node("Bodypart/VBoxContainer2/Name").text = chosenBodypart.name
	rotateBox.value = bodypart.get_parent().get_parent().global_rotation_degrees
	zindexBox.value = bodyparent.z_index
	posXBox.value = bodyparent.position.x
	posYBox.value = bodyparent.position.y
