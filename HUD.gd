extends Control

signal scale_changed(bodypart)

var bodyimage = {
	hips = [],
	middle = [],
	chest = [],
	arm = [],
	forearm = [],
	hand = [],
	neck = [],
	head = []
}

var bodypart = null
var bodyparent = null
var HUD_active = true
var focus = false
onready var posXBox = get_node("Bodypart/VBoxContainer2/Horizontal/SpinBox")
onready var posYBox = get_node("Bodypart/VBoxContainer2/Horizontal/SpinBox2")
onready var rotateBox = get_node("Bodypart/VBoxContainer2/Horizontal3/SpinBox2")
onready var scaleXBox = get_node("Bodypart/VBoxContainer2/Horizontal2/SpinBox2")
onready var scaleYBox = get_node("Bodypart/VBoxContainer2/Horizontal2/SpinBox")
onready var zindexBox = get_node("Bodypart/VBoxContainer2/Horizontal4/SpinBox2")
onready var imgList = get_node("Bodypart/VBoxContainer2/ImageList")
onready var flipH = get_node("Bodypart/VBoxContainer2/HBoxContainer/CheckBox")
onready var flipV = get_node("Bodypart/VBoxContainer2/HBoxContainer/CheckBox2")


func _ready():
	for part in bodyimage:
		print(part.to_upper())
		loadFolder(part)

func _process(delta):
	if bodypart != null:
		if HUD_active == true: #Affecting the body when changing values in the HUD
			#Position
			var distance = bodyparent.get_child(0).position - bodypart.position
			bodyparent.position.x = posYBox.value
			bodyparent.position.y = posXBox.value
			#Rotation
			bodyparent.global_rotation_degrees = rotateBox.value
			#Flip
			bodypart.flip_h = flipH.pressed
			bodypart.flip_v = flipV.pressed
			#Scale
			if floor(bodypart.rotation_degrees) == 90:
				if bodypart.scale.x != scaleXBox.value:
					bodypart.scale.x = scaleXBox.value
					bodypart.get_parent().get_child(1).rect_scale.x = scaleXBox.value
					_on_scaleX_value_changed()
				if bodypart.scale.y != scaleYBox.value:
					bodypart.scale.y = scaleYBox.value
					bodypart.get_parent().get_child(1).rect_scale.y = scaleYBox.value
					_on_scaleY_value_changed()
			else:
				if bodypart.scale.y != scaleXBox.value:
					bodypart.scale.y = scaleXBox.value
					bodypart.get_parent().get_child(1).rect_scale.x = scaleXBox.value
					_on_scaleX_value_changed()
				if bodypart.scale.x != scaleYBox.value:
					bodypart.scale.x = scaleYBox.value
					bodypart.get_parent().get_child(1).rect_scale.y = scaleYBox.value
					_on_scaleY_value_changed()
			#Z index
			bodyparent.z_index = zindexBox.value
		else: #Set values in the HUD when changing on the body
			#Position
			posYBox.value = bodyparent.position.x
			posXBox.value = bodyparent.position.y
			#Rotation
			rotateBox.value = bodyparent.global_rotation_degrees

func _on_body_bodypart_clicked(chosenBodypart):
	$Bodypart.visible = true # Showing the bodypart menu
	$"Character menu".visible = false # Hide Character menu
	bodypart = chosenBodypart
	bodyparent = bodypart.get_parent()
	var partName = bodypart.get_parent().get_child(1).name.split("_")[-1]
	# Set the top title to bodypart's name
	get_node("Bodypart/VBoxContainer2/Name").text = bodyparent.get_child(1).name.to_upper()
	posYBox.value = bodyparent.position.x
	posXBox.value = bodyparent.position.y
	#Rotation
	rotateBox.value = bodypart.get_parent().global_rotation_degrees
	#Flip
	flipH.pressed = bodypart.flip_h
	flipV.pressed = bodypart.flip_v
	#Scale
	if floor(bodypart.rotation_degrees) == 90:
		scaleXBox.value = bodypart.scale.x
		scaleYBox.value = bodypart.scale.y
	else:
		scaleXBox.value = bodypart.scale.y
		scaleYBox.value = bodypart.scale.x
	#Z index
	zindexBox.value = bodyparent.z_index
	#Image list
	imgList.clear()
	for part in bodyimage[partName]:
		imgList.add_item(part[0], part[1])

func _on_scaleY_value_changed():
	if floor(bodypart.rotation_degrees) == 90:
		bodypart.position.x = (bodypart.texture.get_height() * bodypart.scale.y)/2
	else:
		bodypart.position.x = (bodypart.texture.get_width() * bodypart.scale.x)/2
	var button = bodypart.get_parent().get_child(3)
	emit_signal("scale_changed", button)


func _on_scaleX_value_changed():
	var bodyButton = bodypart.get_parent().get_child(1)
	bodyButton.rect_position.y = (bodyButton.rect_size.x * bodyButton.rect_scale.x)/2


func _on_voidClick():
	$Bodypart.visible = false
	$"Character menu".visible = true

func loadFolder(partname):
	var path = "res://Images/"+partname
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	while true:
		var file_name = dir.get_next()
		if file_name == "":
			break #break the while loop when get_next() returns ""
		elif !file_name.begins_with(".") and !file_name.ends_with(".import"):
			print(file_name)
			bodyimage[partname].append([file_name.split(".")[0], load(path + "/" + file_name)])
	print("____________________")
	dir.list_dir_end()


func _on_ImageList_item_activated(index):
	bodypart.texture = imgList.get_item_icon(index)
	if floor(bodypart.rotation_degrees) == 90:
		bodypart.get_parent().get_child(1).rect_size = bodypart.texture.get_size()
	else:
		bodypart.get_parent().get_child(1).rect_size.x = bodypart.texture.get_height()
		bodypart.get_parent().get_child(1).rect_size.y = bodypart.texture.get_width()
	_on_scaleY_value_changed()
	_on_scaleX_value_changed()


func _HUDstate(state):
	HUD_active = state


func _on_mouse_entered():
	focus = true


func _on_mouse_exited():
	focus = false
