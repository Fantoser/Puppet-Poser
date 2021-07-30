extends Control

signal scale_changed(button)
signal send_bodyData(bodypart, datas)

const POSSTEP = 0.1
const SCALESTEP = 0.1
const ROTSTEP = 0.1

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
		loadFolder(part)

func _process(delta):
	if bodypart != null:
		var bodybutton = bodypart.get_parent().get_child(1)
		var prevLimb = bodypart.get_parent().get_parent()
		var defaultPos = Vector2(0, 0)
		if prevLimb.get_child(1) is ToolButton:
			defaultPos[0] = prevLimb.get_child(1).rect_size.y * prevLimb.get_child(1).rect_scale.y
		if HUD_active == true: #Affecting the body when changing values in the HUD
			#Position
			if bodyparent.position != Vector2(defaultPos[0] + posYBox.value, posXBox.value):
				bodyparent.position.x = defaultPos[0] + posYBox.value
				bodyparent.position.y = posXBox.value
				var relativePos = Vector2(stepify(bodyparent.position.x - bodybutton.rect_size.y * bodybutton.rect_scale.y, POSSTEP), stepify(bodyparent.position.y, POSSTEP))
				get_parent().body[bodybutton.name]["position"] = relativePos
			#Rotation
			if stepify(bodyparent.rotation_degrees, ROTSTEP) != stepify(rotateBox.value, ROTSTEP):
				bodyparent.rotation_degrees = stepify(rotateBox.value, ROTSTEP)
				get_parent().body[bodybutton.name]["rotation"] = bodyparent.rotation_degrees
			#Flip
			if bodypart.flip_h != flipH.pressed:
				bodypart.flip_h = flipH.pressed
				get_parent().body[bodybutton.name]["flipH"] = flipH.pressed
			if bodypart.flip_v != flipV.pressed:
				bodypart.flip_v = flipV.pressed
				get_parent().body[bodybutton.name]["flipV"] = flipV.pressed
			#Scale
			if floor(bodypart.rotation_degrees) == 90:
				if stepify(bodypart.scale.x, SCALESTEP) != stepify(scaleXBox.value, SCALESTEP):
					bodypart.scale.x = scaleXBox.value
					bodypart.get_parent().get_child(1).rect_scale.x = scaleXBox.value
					_on_scaleX_value_changed()
					get_parent().body[bodybutton.name]["scale"] = bodypart.scale
				if stepify(bodypart.scale.y, SCALESTEP) != stepify(scaleYBox.value, SCALESTEP):
					bodypart.scale.y = scaleYBox.value
					bodypart.get_parent().get_child(1).rect_scale.y = scaleYBox.value
					_on_scaleY_value_changed()
					get_parent().body[bodybutton.name]["scale"] = bodypart.scale
			else:
				if stepify(bodypart.scale.y, SCALESTEP) != stepify(scaleXBox.value, SCALESTEP):
					bodypart.scale.y = stepify(scaleXBox.value, SCALESTEP)
					bodypart.get_parent().get_child(1).rect_scale.x = stepify(scaleXBox.value, SCALESTEP)
					_on_scaleX_value_changed()
					get_parent().body[bodybutton.name]["scale"] = bodypart.scale
				if stepify(bodypart.scale.x, SCALESTEP) != stepify(scaleYBox.value, SCALESTEP):
					bodypart.scale.x = stepify(scaleYBox.value, SCALESTEP)
					bodypart.get_parent().get_child(1).rect_scale.y = stepify(scaleYBox.value, SCALESTEP)
					_on_scaleY_value_changed()
					get_parent().body[bodybutton.name]["scale"] = bodypart.scale
			#Z index
			if bodyparent.z_index != zindexBox.value:
				bodyparent.z_index = zindexBox.value
				get_parent().body[bodybutton.name]["z_index"] = bodyparent.z_index
		else: #Set values in the HUD when changing on the body
			#Position
			if posYBox.value != bodyparent.position.x - defaultPos[0] or posXBox.value != bodyparent.position.y - defaultPos[1]:
				posYBox.value = bodyparent.position.x - defaultPos[0]
				posXBox.value = bodyparent.position.y - defaultPos[1]
				get_parent().body[bodybutton.name]["position"] = bodyparent.position - defaultPos
			#Rotation
			if rotateBox.value != bodyparent.rotation_degrees:
				rotateBox.value = bodyparent.rotation_degrees
				get_parent().body[bodybutton.name]["rotation"] = bodyparent.rotation_degrees

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
	rotateBox.value = bodyparent.rotation_degrees
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
	var bodybutton = bodypart.get_parent().get_child(1)
#	if floor(bodypart.rotation_degrees) == 90:
#		bodypart.position.x = bodybutton.rect_size.y * bodybutton.rect_scale.y + get_parent().body[bodypart.get_parent().get_child(1).name]["position"][1]
#	else:
#		bodypart.position.x = (bodypart.texture.get_width() * bodypart.scale.x)/2
	bodypart.position.x = (bodybutton.rect_size.y * bodybutton.rect_scale.y)/2
	if bodypart.get_parent().get_child(0).get_child_count() > 2:
		var nextLimb = bodypart.get_parent().get_child(0)
		nextLimb.position.x = bodybutton.rect_size.y * bodybutton.rect_scale.y
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
	print(partname.to_upper())
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
#	if floor(bodypart.rotation_degrees) == 90:
#		bodypart.get_parent().get_child(1).rect_size = bodypart.texture.get_size()
#	else:
	bodypart.get_parent().get_child(1).rect_size.x = bodypart.texture.get_height()
	bodypart.get_parent().get_child(1).rect_size.y = bodypart.texture.get_width()
	_on_scaleY_value_changed()
	_on_scaleX_value_changed()

func emit_bodyData(bodyparent):
#	bodypart, position, scale, rotation, flipH, flipV, z_index, image
	var bodyChild = bodyparent.get_child(2)
	var relativePos = bodyparent.position
	if bodyparent.get_parent().get_child(1) is ToolButton:
		relativePos[0] = bodyparent.position.x - bodyparent.get_parent().get_child(1).rect_size.y * bodyparent.get_parent().get_child(1).rect_scale.y
	emit_signal("send_bodyData", bodyparent.get_child(1).name, {position = relativePos, scale = bodyChild.scale,
		rotation = bodyparent.rotation, flipH = bodyChild.flip_h, flilpV = bodyChild.flip_v, z_index = bodyparent.z_index, image = bodyChild.texture})

func _HUDstate(state):
	HUD_active = state


func _on_mouse_entered():
	focus = true


func _on_mouse_exited():
	focus = false
