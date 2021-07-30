extends Node2D

var root
var joints = []
var buttons = []
var total_length = 0
var distance = null
var moving = false
var target = null
var limb = null
var movebase = false

# Called when the node enters the scene tree for the first time.
func _ready():
	load_limb_info()
	pass # Replace with function body.

func load_limb_info():
	for button in buttons:
		button.queue_free()
	buttons = []
	joints = []
	var obj = get_child(0)
	while obj.get_child_count() > 0 and obj is Position2D:
		var ch = obj.get_child(0)
		joints.append([obj, ch.position, ch])
		add_button(obj)
		obj = ch

	var button = Button.new()
	button.rect_size.x = 22
	button.rect_size.y = 22
	button.rect_pivot_offset = button.rect_size/2
	button.set_focus_mode(0)
	button.rect_position = get_child(0).position - button.rect_pivot_offset
	button.connect( "button_down", self, "move_base", [true])
	button.connect( "button_up", self, "move_base", [false])
	get_child(0).add_child(button)
	buttons.append(button)

func add_button(parent):
	if parent.get_child(0) is Position2D:
		var button = Button.new()
		button.rect_size.x = 22
		button.rect_size.y = 22
		button.rect_pivot_offset = button.rect_size/2
		button.set_focus_mode(0)
		#Position of the button
#		button.rect_position = parent.get_child(0).position - button.rect_pivot_offset
		parent.add_child(button)
		var sprite = parent.get_child(2)
		var buttonDistance = sprite.texture.get_height() * sprite.scale.y
#		var direction = Vector2(cos(button.get_parent().get_child(0).rotation), sin(button.get_parent().get_child(0).rotation))
		button.rect_position = Vector2(0, -button.rect_size.y/2)
		button.rect_position.x += buttonDistance
#		button.rect_position += direction * buttonDistance
		#Set connections for grabbing the button and releasing it
		button.connect("button_down", self, "start_moving", [button, parent])
		button.connect("button_up", self, "stop_moving", [button])
		buttons.append(button)

func start_moving(currentButton, currentLimb):
	moving = true
	target = currentButton
	limb = currentLimb
#	print(currentTarget.get_parent().name)

func stop_moving(currentButton):
	moving = false
	distance = null
	#Positioning the button
	var sprite = currentButton.get_parent().get_child(2)
	var buttonDistance = sprite.texture.get_height() * sprite.scale.y
	if sprite.rotation == 0:
		buttonDistance = sprite.texture.get_width() * sprite.scale.x
	currentButton.rect_position = Vector2(0, -currentButton.rect_size.y/2)
	currentButton.rect_position.x += buttonDistance
#	if sprite.get_parent().get_child_count() > 2:
##		sprite.get_parent().get_child(0).position = root.body[currentButton.get_parent().get_child(1).name]["position"]
#		sprite.get_parent().get_child(0).position.x = buttonDistance

func calc_fk(currentTarget, currentLimb):
	if distance == null:
		distance = get_global_mouse_position() - target.rect_global_position
	currentTarget.rect_global_position = get_global_mouse_position() - distance
	var offset = (target.rect_global_position + target.rect_pivot_offset) - limb.global_position
	var r = atan2(offset.y, offset.x)
	currentLimb.global_rotation = r
#	if offset.length() > total_length:
#		for joint in joints:
#			joint[0].rotation = 0
#			#joint[2].position = joint[1]
#		var r = atan2(offset.y, offset.x)
#		joints[0][0].global_rotation = r

func set_distance(currentLimb, currentDistance):
	var direction = (limb.global_position - limb.get_parent().global_position).normalized()
	currentLimb.global_position = limb.get_parent().global_position
	currentLimb.global_position += direction * currentDistance

func move_base(state):
	movebase = state

func rename(limb, names, editor):
	if limb.get_child_count() > 1 and names.size() > 0:
		limb.get_child(1).name = names[0]
		limb.get_child(1).connect("button_down", editor, "emit_body_signal", [limb.get_child(2)])
		var defaultDistance = Vector2(0, 0)
		if limb.get_parent().get_child(1) is ToolButton:
			defaultDistance[0] = limb.get_parent().get_child(1).rect_size.y * limb.get_parent().get_child(1).rect_scale.y
		editor.body[names[0]] = {
			object = limb,
			image = limb.get_child(2).texture,
			position = limb.position - defaultDistance,
			scale = limb.get_child(2).scale,
			rotation = limb.global_rotation_degrees,
			flipH = limb.get_child(2).flip_h,
			flipV = limb.get_child(2).flip_v,
			z_index = limb.z_index
		}
		names.pop_front()
		rename(limb.get_child(0), names, editor)

func _process(delta):
	update()
	if moving == true:
		calc_fk(target, limb)
	if movebase == true:
#		var currentDistance = get_global_mouse_position() - self.global_position
		self.global_position = get_global_mouse_position()

#func _draw():
#	#var col = Color(1, 1, 1)
#	var j_count = joints.size()
#	for i in range(j_count):
#		var joint = joints[i][0]
#		var j_pos = joint.global_position
#		var c_pos = joint.to_global(joints[i][1])
#		var col = Color(i * 1.0 / j_count, 0, 0)

#		draw_circle(to_local(j_pos), 5, col)
#		draw_line(to_local(j_pos), to_local(c_pos), col, 5)


func _on_HUD_scale_changed(button):
	var distance = 0
	if button.get_parent().get_child_count() > 2:
		distance = button.get_parent().get_child(0).position.x
	stop_moving(button)
#	if button.get_parent().get_child_count() > 2:
#		button.get_parent().get_child(0).position.x = distance
#	print(bodypart.get_parent().get_parent().get_child(2))
