extends Node2D

signal body_clicked(bodypart)
signal voidClick()
signal HUDstate(state)

var limb = preload("res://FKLimb.tscn")
var arm = preload("res://FKArm.tscn")
var head = preload("res://FKHead.tscn")
var buttons = []
var body = {
	hips = {object = null, image = null, position = Vector2(0, 0), scale = [0, 0]},
	middle = {object = null, image = null, position = Vector2(0, 0), scale = [0, 0]},
	chest = {object = null, image = null, position = Vector2(0, 0), scale = [0, 0]},
	left_arm = {object = null, image = null, position = Vector2(0, 0), scale = [0, 0]},
	left_forearm = {object = null, image = null, position = Vector2(0, 0), scale = [0, 0]},
	left_hand = {object = null, image = null, position = Vector2(0, 0), scale = [0, 0]},
	right_arm = {object = null, image = null, position = Vector2(0, 0), scale = [0, 0]},
	right_forearm = {object = null, image = null, position = Vector2(0, 0), scale = [0, 0]},
	right_hand = {object = null, image = null, position = Vector2(0, 0), scale = [0, 0]},
	neck = {object = null, image = null, position = Vector2(0, 0), scale = [0, 0]},
	head = {object = null, image = null, position = Vector2(0, 0), scale = [0, 0]}
}

func _ready():

	setLimb($FKLimb, ["hips", "middle", "chest"], Vector2(0, 0), -90)
	$FKLimb.set_z_index(-1)
	for button in $FKLimb.buttons:
		buttons.append(button)

	var leftarm = arm.instance()
	$FKLimb.get_node("first/second/third/fourth").add_child(leftarm)
	setLimb(leftarm, ["left_arm", "left_forearm", "left_hand"], Vector2(100, 0), 90)
	leftarm.set_z_index(1)
	leftarm.connect("HUD_state", $FKLimb, "emit_HUD_signal")
	for button in leftarm.buttons:
		buttons.append(button)

	var rightarm = arm.instance()
	$FKLimb.get_node("first/second/third/fourth").add_child(rightarm)
	setLimb(rightarm, ["right_arm", "right_forearm", "right_hand"], Vector2(-100, 0), -90)
	rightarm.set_z_index(1)
	rightarm.connect("HUD_state", $FKLimb, "emit_HUD_signal")
	for button in rightarm.buttons:
		buttons.append(button)

	var neck = head.instance()
	$FKLimb.get_node("first/second/third/fourth").add_child(neck)
	for child in neck.get_node("first/second/third").get_children():
		child.queue_free()
	setLimb(neck, ["neck", "head"], Vector2(0, -30), 0)
	neck.set_z_index(1)
	neck.connect("HUD_state", $FKLimb, "emit_HUD_signal")
	neck.load_limb_info()
	for button in neck.buttons:
		buttons.append(button)
	

func setLimb(limb, nameArray, position, rotation):
	limb.global_position += position
	limb.global_rotation_degrees += rotation
	limb.rename(limb.get_child(0), nameArray, self)

func emit_body_signal(bodypart):
	emit_signal("body_clicked", bodypart)

func _process(delta):
	if Input.is_action_just_pressed("W"):
		$FKLimb.set_distance($FKLimb/first/second, 200)
		$FKLimb.load_limb_info()
	if Input.is_action_just_pressed("S"):
		$FKLimb.set_distance($FKLimb/first/second, 100)
		$FKLimb.load_limb_info()
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
	for button in buttons:
		button.visible = true


func _on_Area2D_mouse_exited():
	for button in buttons:
		button.visible = false
