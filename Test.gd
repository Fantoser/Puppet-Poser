extends Node2D


var limb = preload("res://FKLimb.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():

	$FKLimb.global_rotation_degrees = -90
	$FKLimb.rename(["hip", "middle", "chest"])
	$FKLimb.set_z_index(-1)

	var leftarm = limb.instance()
	$FKLimb.get_node("first/second/third/fourth").add_child(leftarm)
	leftarm.global_position += Vector2(100, 0)
	leftarm.global_rotation_degrees += 90
	leftarm.rename(["arm", "forearm", "hand"])
	leftarm.set_z_index(1)

	var rightarm = limb.instance()
	$FKLimb.get_node("first/second/third/fourth").add_child(rightarm)
	rightarm.global_position -= Vector2(100, 0)
	rightarm.global_rotation_degrees -= 90
	rightarm.rename(["arm", "forearm", "hand"])
	rightarm.set_z_index(1)

	var neck = limb.instance()
	$FKLimb.get_node("first/second/third/fourth").add_child(neck)
	neck.global_position -= Vector2(0, 30)
	for child in neck.get_node("first/second/third").get_children():
		child.queue_free()
	neck.rename(["neck", "head"])
	neck.set_z_index(1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("W"):
		$FKLimb.set_distance($FKLimb/first/second, 200)
		$FKLimb.load_limb_info()
	if Input.is_action_just_pressed("S"):
		$FKLimb.set_distance($FKLimb/first/second, 100)
		$FKLimb.load_limb_info()
