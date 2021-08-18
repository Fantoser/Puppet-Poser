extends Control

signal scale_changed(button)
signal send_bodyData(bodypart, datas)

const POSSTEP = 0.1
const SCALESTEP = 0.1
const ROTSTEP = 0.1

var bodyimage = {
	hips = {},
	middle = {},
	chest = {},
	arm = {},
	forearm = {},
	hand = {},
	neck = {},
	head = {}
}

var bodypart = null
var bodyParent = null
var bodyButton = null
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
onready var PoseInput = get_node("Character menu/VBoxContainer/HBoxContainer2/VBoxContainer/PoseInput")
onready var PoseList = get_node("Character menu/VBoxContainer/HBoxContainer2/VBoxContainer/PoseList")
onready var PoseMessage = get_node("Character menu/VBoxContainer/PoseMessage")


func _ready():
	for part in bodyimage:
		loadFolder(part)

func _process(delta):
	if bodypart != null:
		var bodybutton = bodypart.get_parent().get_child(1)
		var defaultPos = Vector2(0, 0)
		if bodyParent.get_parent() is Position2D:
			var prevLimb = bodypart.get_parent().get_parent()
			if prevLimb.get_child(1) is ToolButton:
				defaultPos[0] = prevLimb.get_child(1).rect_size.y * prevLimb.get_child(1).rect_scale.y
		if HUD_active == true and $Bodypart.visible == true: #Affecting the body when changing values in the HUD
			#Position
			if bodyParent.position != Vector2(defaultPos[0] + posYBox.value, posXBox.value):
				if bodyParent.get_parent() is Position2D:
					bodyParent.position.x = defaultPos[0] + posYBox.value
					bodyParent.position.y = posXBox.value
					var relativePos = Vector2(stepify(bodyParent.position.x - bodybutton.rect_size.y * bodybutton.rect_scale.y, POSSTEP), stepify(bodyParent.position.y, POSSTEP))
					get_parent().body[bodybutton.name]["position"] = relativePos
				else:
					bodyParent.get_parent().global_position.x = stepify(posXBox.value, POSSTEP)
					bodyParent.get_parent().global_position.y = stepify(posYBox.value, POSSTEP)
					get_parent().body[bodybutton.name]["position"] = bodyParent.get_parent().global_position
			#Rotation
			if stepify(bodyParent.rotation_degrees, ROTSTEP) != stepify(rotateBox.value, ROTSTEP):
				bodyParent.rotation_degrees = stepify(rotateBox.value, ROTSTEP)
				get_parent().body[bodybutton.name]["rotation"] = stepify(bodyParent.rotation_degrees, ROTSTEP)
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
					_on_scale_value_changed()
					get_parent().body[bodybutton.name]["scale"] = bodypart.scale
				if stepify(bodypart.scale.y, SCALESTEP) != stepify(scaleYBox.value, SCALESTEP):
					bodypart.scale.y = scaleYBox.value
					bodypart.get_parent().get_child(1).rect_scale.y = scaleYBox.value
					_on_scale_value_changed()
					get_parent().body[bodybutton.name]["scale"] = bodypart.scale
			else:
				if stepify(bodypart.scale.y, SCALESTEP) != stepify(scaleXBox.value, SCALESTEP):
					bodypart.scale.y = stepify(scaleXBox.value, SCALESTEP)
					bodypart.get_parent().get_child(1).rect_scale.x = stepify(scaleXBox.value, SCALESTEP)
					_on_scale_value_changed()
					get_parent().body[bodybutton.name]["scale"] = bodypart.scale
				if stepify(bodypart.scale.x, SCALESTEP) != stepify(scaleYBox.value, SCALESTEP):
					bodypart.scale.x = stepify(scaleYBox.value, SCALESTEP)
					bodypart.get_parent().get_child(1).rect_scale.y = stepify(scaleYBox.value, SCALESTEP)
					_on_scale_value_changed()
					get_parent().body[bodybutton.name]["scale"] = bodypart.scale
			#Z index
			if bodyParent.z_index != zindexBox.value:
				bodyParent.z_index = zindexBox.value
				get_parent().body[bodybutton.name]["z_index"] = bodyParent.z_index
		else: #Set values in the HUD when changing on the body
			#Position
			if bodyParent.get_parent() is Position2D:
				if posYBox.value != bodyParent.position.x - defaultPos[0] or posXBox.value != bodyParent.position.y - defaultPos[1]:
					posYBox.value = bodyParent.position.x - defaultPos[0]
					posXBox.value = bodyParent.position.y - defaultPos[1]
					get_parent().body[bodybutton.name]["position"] = bodyParent.position - defaultPos
			#Rotation
			if stepify(rotateBox.value, ROTSTEP) != stepify(bodyParent.rotation_degrees, ROTSTEP):
				rotateBox.value = stepify(bodyParent.rotation_degrees, ROTSTEP)
				get_parent().body[bodybutton.name]["rotation"] = stepify(bodyParent.rotation_degrees, ROTSTEP)

func _on_body_bodypart_clicked(chosenBodypart):
	$Bodypart.visible = true # Showing the bodypart menu
	$"Character menu".visible = false # Hide Character menu
	bodypart = chosenBodypart
	bodyParent = bodypart.get_parent()
	bodyButton = bodyParent.get_child(1)
	var partName = bodyButton.name.split("_")[-1]
	# Set the top title to bodypart's name
	get_node("Bodypart/VBoxContainer2/Name").text = bodyParent.get_child(1).name.to_upper()
	#Position
	var defaultPos = Vector2(0, 0)
	if bodyParent.get_parent() is Position2D:
		var prevLimb = bodyParent.get_parent()
		if prevLimb.get_child(1) is ToolButton:
			defaultPos[0] = prevLimb.get_child(1).rect_size.y * prevLimb.get_child(1).rect_scale.y
	posYBox.value = bodyParent.position.x - defaultPos[0]
	posXBox.value = bodyParent.position.y
	if !bodyParent.get_parent() is Position2D:
		posXBox.value = stepify(bodyParent.get_parent().global_position.x, POSSTEP)
		posYBox.value = stepify(bodyParent.get_parent().global_position.y, POSSTEP)
	#Rotation
	rotateBox.value = bodyParent.rotation_degrees
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
	zindexBox.value = bodyParent.z_index
	#Image list
	imgList.clear()
	for part in bodyimage[partName]:
		imgList.add_item(part, bodyimage[partName][part])

func position(pos):
	var defaultPos = Vector2(0, 0)
	if bodyParent.get_parent() is Position2D:
		var prevLimb = bodypart.get_parent().get_parent()
		if prevLimb.get_child(1) is ToolButton:
			defaultPos[0] = prevLimb.get_child(1).rect_size.y * prevLimb.get_child(1).rect_scale.y
	if bodyParent.position != Vector2(defaultPos[0] + pos[1], pos[0]):
		bodyParent.position.y = pos[1]
		bodyParent.position.x = defaultPos[0] + pos[0]
		var relativePos = Vector2(stepify(bodyParent.position.x - bodyButton.rect_size.y * bodyButton.rect_scale.y, POSSTEP), stepify(bodyParent.position.y, POSSTEP))
		get_parent().body[bodyButton.name]["position"] = pos

func _on_scale_value_changed():
	bodyButton.rect_size.x = bodypart.texture.get_height()
	bodyButton.rect_size.y = bodypart.texture.get_width()
	bodyButton.rect_position.y = (bodyButton.rect_size.x * bodyButton.rect_scale.x)/2
	if bodypart.rotation_degrees == 90:
		bodypart.position.x = (bodyButton.rect_size.y * bodyButton.rect_scale.y)/2
	else:
		bodypart.position.x = (bodyButton.rect_size.x * bodyButton.rect_scale.x)/2
	if bodypart.get_parent().get_child(0).get_child_count() > 2:
		var nextLimb = bodypart.get_parent().get_child(0)
		nextLimb.position.x = bodyButton.rect_size.y * bodyButton.rect_scale.y
	var button = bodypart.get_parent().get_child(3)
	emit_signal("scale_changed", button)


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
			var img = Image.new()
			img.load(path + "/" + file_name)
			var tex = ImageTexture.new()
			tex.create_from_image(img)
			bodyimage[partname][file_name.split(".")[0]] = tex
	print("____________________")
	dir.list_dir_end()


func _on_ImageList_item_activated(index):
	bodypart.texture = imgList.get_item_icon(index)
	var partName = bodypart.get_parent().get_child(1).name.split("_")[-1]
	get_parent().body[bodyButton.name]["image"] = imgList.get_item_text(index)
	bodypart.get_parent().get_child(1).rect_size.x = bodypart.texture.get_height()
	bodypart.get_parent().get_child(1).rect_size.y = bodypart.texture.get_width()
	_on_scale_value_changed()


func _HUDstate(state):
	HUD_active = state


func _on_mouse_entered():
	focus = true


func _on_mouse_exited():
	focus = false


func _on_Save_Pose_pressed():
	if PoseInput.text != "" and get_parent().poses.has(PoseInput.text) == false:
		get_parent().poses[PoseInput.text] = get_parent().body.duplicate(true)
		PoseList.add_item(PoseInput.text)
		PoseInput.text = ""


func _on_Delete_Pose_pressed():
	if PoseList.get_selected_items().size() > 0:
		var selected_item = PoseList.get_selected_items()[0]
		get_parent().poses.erase(PoseList.get_item_text(selected_item))
		PoseList.remove_item(selected_item)


func _on_PoseList_item_activated(index):
	var pose = get_parent().poses[PoseList.get_item_text(index)]
	get_parent().body = pose.duplicate(true)
	for currentPart in pose:
		bodyParent = pose[currentPart]["object"]
		bodyButton = bodyParent.get_child(1)
		bodypart = bodyParent.get_child(2)
		var partName = bodyButton.name.split("_")[-1]
		bodypart.texture = bodyimage[partName][pose[currentPart]["image"]]
		bodyParent.rotation_degrees = pose[currentPart]["rotation"]
		if floor(bodypart.rotation_degrees) == 90:
			bodyButton.rect_scale = pose[currentPart]["scale"]
		else:
			bodyButton.rect_scale.x = pose[currentPart]["scale"][1]
			bodyButton.rect_scale.y = pose[currentPart]["scale"][0]
		bodypart.scale = pose[currentPart]["scale"]
		if bodyParent.get_parent() is Position2D:
			position(pose[currentPart]["position"])
		else:
			bodyParent.get_parent().global_position = pose[currentPart]["position"]
		_on_scale_value_changed()
