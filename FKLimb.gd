extends Node2D


var joints = []
var buttons = []
var total_length = 0
var distance = null
var moving = false
var target = null
var limb = null
var parent = null
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

func add_button(parent):
	if parent.get_child(0) is Position2D:
		var button = Button.new()
		button.rect_size.x = 22
		button.rect_size.y = 22
		button.rect_pivot_offset = button.rect_size/2
		button.set_focus_mode(0)
		button.rect_position = parent.get_child(0).position - button.rect_pivot_offset
		button.connect("button_down", self, "start_moving", [button, parent])
		button.connect("button_up", self, "stop_moving")
		parent.add_child(button)
		buttons.append(button)

func start_moving(currentTarget, currentLimb):
	moving = true
	target = currentTarget
	limb = currentLimb

func stop_moving():
	moving = false
	distance = null
	target.rect_position = target.get_parent().get_child(0).position - target.rect_pivot_offset

func calc_fk(target, limb):
	if distance == null:
		distance = get_global_mouse_position() - target.rect_global_position
	target.rect_global_position = get_global_mouse_position() - distance
	var offset = (target.rect_global_position + target.rect_pivot_offset) - limb.global_position
	var r = atan2(offset.y, offset.x)
	limb.global_rotation = r
#	if offset.length() > total_length:
#		for joint in joints:
#			joint[0].rotation = 0
#			#joint[2].position = joint[1]
#		var r = atan2(offset.y, offset.x)
#		joints[0][0].global_rotation = r

func set_distance(limb, distance):
	var direction = (limb.global_position - limb.get_parent().global_position).normalized()
	limb.global_position = limb.get_parent().global_position
	limb.global_position += direction * distance

func move_base(state):
	movebase = state

func rename(names):
	for i in range(get_child_count()):
		if get_child(i).get_child_count() > 0:
			get_child(i).get_child(1).name = names[i]

func _process(delta):
	update()
	if moving == true:
		calc_fk(target, limb)
	if movebase == true:
		var distance = get_global_mouse_position() - self.global_position
		self.global_position = get_global_mouse_position()

func _draw():
	#var col = Color(1, 1, 1)
	var j_count = joints.size()
	for i in range(j_count):
		var joint = joints[i][0]
		var j_pos = joint.global_position
		var c_pos = joint.to_global(joints[i][1])
		var col = Color(i * 1.0 / j_count, 0, 0)

#		draw_circle(to_local(j_pos), 5, col)
#		draw_line(to_local(j_pos), to_local(c_pos), col, 5)
