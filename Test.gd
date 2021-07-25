extends Node2D

signal body_clicked(bodypart)
signal voidClick()

var limb = preload("res://FKLimb.tscn")
var arm = preload("res://FKArm.tscn")
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

	var leftarm = arm.instance()
	$FKLimb.get_node("first/second/third/fourth").add_child(leftarm)
	setLimb(leftarm, ["left_arm", "left_forearm", "left_hand"], Vector2(100, 0), 90)
	leftarm.set_z_index(1)
	leftarm.connect("HUD_state", $FKLimb, "emit_HUD_signal")

	var rightarm = arm.instance()
	$FKLimb.get_node("first/second/third/fourth").add_child(rightarm)
	setLimb(rightarm, ["right_arm", "right_forearm", "right_hand"], Vector2(-100, 0), -90)
	rightarm.set_z_index(1)
	rightarm.connect("HUD_state", $FKLimb, "emit_HUD_signal")

	var neck = limb.instance()
	$FKLimb.get_node("first/second/third/fourth").add_child(neck)
	for child in neck.get_node("first/second/third").get_children():
		child.queue_free()
#	neck.get_node("first/second").get_child(2).queue_free()
	setLimb(neck, ["neck", "head"], Vector2(0, -30), 0)
	neck.set_z_index(1)
	neck.connect("HUD_state", $FKLimb, "emit_HUD_signal")
	

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


func _on_body_HUD_state(state):
	$HUD.HUD_active = state


func _on_Area2D_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("mouseLeft"):
		emit_signal("voidClick")
