extends Node2D

signal body_clicked(bodypart)
signal voidClick()
signal HUDstate(state)

var limb = preload("res://FKBody.tscn")
var arm = preload("res://FKArm.tscn")
var head = preload("res://FKHead.tscn")
var part = preload("res://part.tscn")
onready var HUD = get_node("HUD")
onready var currentPart = $"bodyParent"
var buttons = []
var mouseList = []
var body = {
	hips = {},
	middle = {},
	chest = {},
	left_arm = {},
	left_forearm = {},
	left_hand = {},
	right_arm = {},
	right_forearm = {},
	right_hand = {},
	neck = {},
	head = {}
}
var poses = {}

#func _ready():
#
#	setLimb($FKBody, ["hips", "middle", "chest"], Vector2(0, 0), -90)
#	$FKBody.set_z_index(-1)
#	for button in $FKBody.buttons:
#		buttons.append(button)
#	$FKBody.root = self
#
#	var leftarm = arm.instance()
#	$FKBody.get_node("first/second/third/fourth").add_child(leftarm)
#	setLimb(leftarm, ["left_arm", "left_forearm", "left_hand"], Vector2(100, 0), 90)
#	leftarm.set_z_index(1)
#	leftarm.connect("HUD_state", $FKBody, "emit_HUD_signal")
#	for button in leftarm.buttons:
#		buttons.append(button)
#	leftarm.root = self
#
#	var rightarm = arm.instance()
#	$FKBody.get_node("first/second/third/fourth").add_child(rightarm)
#	setLimb(rightarm, ["right_arm", "right_forearm", "right_hand"], Vector2(-100, 0), -90)
#	rightarm.set_z_index(1)
#	rightarm.connect("HUD_state", $FKBody, "emit_HUD_signal")
#	for button in rightarm.buttons:
#		buttons.append(button)
#	rightarm.root = self
#
#	var neck = head.instance()
#	$FKBody.get_node("first/second/third/fourth").add_child(neck)
#	for child in neck.get_node("first/second/third").get_children():
#		child.queue_free()
#	setLimb(neck, ["neck", "head"], Vector2(0, -30), 0)
#	neck.set_z_index(1)
#	neck.connect("HUD_state", $FKBody, "emit_HUD_signal")
#	neck.load_limb_info()
#	for button in neck.buttons:
#		buttons.append(button)
#	neck.root = self


func setLimb(limb, nameArray, position, rotation):
	limb.global_position += position
	limb.global_rotation_degrees += rotation
	limb.rename(limb.get_child(0), nameArray, self)

func emit_body_signal(bodypart):
	emit_signal("body_clicked", bodypart)

func _process(delta):
	if Input.is_action_just_pressed("Q"):
		print("==============")
		print(body)
	if get_global_mouse_position().x > $HUD.rect_position.x:
		if $HUD.HUD_active == false:
			emit_signal("HUDstate", true)
			for button in buttons:
				button.visible = false
	else:
		if $HUD.HUD_active == true and $HUD.focus == false:
			emit_signal("HUDstate", false)
			for button in buttons:
				button.visible = true

func _unhandled_input(event):
	var highZ = -999
	var clickedNode
	if event.is_action_pressed("mouseLeft"):
		if mouseList.size() > 0: #Check if there any objectt under the mouse
			for node in mouseList:
				if node.z_index > highZ:
					highZ = node.z_index
					clickedNode = node
			if clickedNode.name == "FKButton": 
				#If the click happen on a FKbutton, start dragging that part
				clickedNode.get_parent().start_moving()
			HUD.setHUD(clickedNode.get_parent())
		else:
			#If nothing under the mouse, that's a voidclick
			emit_signal("voidClick")

func _on_HUD_send_bodyData(bodypart, datas):
	for data in datas:
		body[bodypart][data] = datas[data]

func _get_body():
	return body

func set_limb_rotation(bodypart_name, rot):
	body[bodypart_name]["rotation"] = rot
	pass

func _handle_mouseList(node, state):
	if state == false:
		if mouseList.has(node):
			mouseList.erase(node)
	if state == true:
		if !mouseList.has(node):
			mouseList.append(node)
