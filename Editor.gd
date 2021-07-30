extends Node2D

signal body_clicked(bodypart)
signal voidClick()
signal HUDstate(state)

var limb = preload("res://FKBody.tscn")
var arm = preload("res://FKArm.tscn")
var head = preload("res://FKHead.tscn")
var buttons = []
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

func _ready():

	setLimb($FKBody, ["hips", "middle", "chest"], Vector2(0, 0), -90)
	$FKBody.set_z_index(-1)
	for button in $FKBody.buttons:
		buttons.append(button)
	$FKBody.root = self

	var leftarm = arm.instance()
	$FKBody.get_node("first/second/third/fourth").add_child(leftarm)
	setLimb(leftarm, ["left_arm", "left_forearm", "left_hand"], Vector2(100, 0), 90)
	leftarm.set_z_index(1)
	leftarm.connect("HUD_state", $FKBody, "emit_HUD_signal")
	for button in leftarm.buttons:
		buttons.append(button)
	leftarm.root = self

	var rightarm = arm.instance()
	$FKBody.get_node("first/second/third/fourth").add_child(rightarm)
	setLimb(rightarm, ["right_arm", "right_forearm", "right_hand"], Vector2(-100, 0), -90)
	rightarm.set_z_index(1)
	rightarm.connect("HUD_state", $FKBody, "emit_HUD_signal")
	for button in rightarm.buttons:
		buttons.append(button)
	rightarm.root = self

	var neck = head.instance()
	$FKBody.get_node("first/second/third/fourth").add_child(neck)
	for child in neck.get_node("first/second/third").get_children():
		child.queue_free()
	setLimb(neck, ["neck", "head"], Vector2(0, -30), 0)
	neck.set_z_index(1)
	neck.connect("HUD_state", $FKBody, "emit_HUD_signal")
	neck.load_limb_info()
	for button in neck.buttons:
		buttons.append(button)
	neck.root = self

	print(body)

func setLimb(limb, nameArray, position, rotation):
	limb.global_position += position
	limb.global_rotation_degrees += rotation
	limb.rename(limb.get_child(0), nameArray, self)

func emit_body_signal(bodypart):
	emit_signal("body_clicked", bodypart)

func _process(delta):
	if Input.is_action_just_pressed("W"):
		$FKBody.set_distance($FKBody/first/second, 200)
		$FKBody.load_limb_info()
	if Input.is_action_just_pressed("S"):
		$FKBody.set_distance($FKBody/first/second, 100)
		$FKBody.load_limb_info()
	if Input.is_action_just_pressed("Q"):
		print(body)
		print("==============")
	if get_global_mouse_position().x > $HUD.rect_position.x:
		if $HUD.HUD_active == false:
			emit_signal("HUDstate", true)
#			print(get_global_mouse_position().x)
			for button in buttons:
				button.visible = false
	else:
		if $HUD.HUD_active == true and $HUD.focus == false:
			emit_signal("HUDstate", false)
#			print(get_global_mouse_position().x)
			for button in buttons:
				button.visible = true

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("mouseLeft"):
		emit_signal("voidClick")


func _on_Area2D_mouse_entered():
#	for button in buttons:
#		button.visible = true
	pass


func _on_Area2D_mouse_exited():
#	for button in buttons:
#		button.visible = false
	pass


func _on_HUD_send_bodyData(bodypart, datas):
	for data in datas:
		body[bodypart][data] = datas[data]

func _get_body():
	return body
