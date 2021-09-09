extends Position2D

var ID = 0
var moving = false
var buttonOffset
var is_mouse_over = false
onready var HUD = get_node("../HUD")
onready var Editor = get_node("..")
var part

signal bodyButton_mouse_isOver(node, state)
signal FKButton_mouse_isOver(node, state)

# Called when the node enters the scene tree for the first time.
func _ready():
	part = load("res://part.tscn")

func spawnChild():
	var newPart = part.instance()
	self.add_child(newPart)
	newPart.HUD = HUD
	newPart.Editor = Editor
	newPart.z_index = self.z_index+1
	newPart.get_node("bodyButton").z_index = 10+newPart.z_index+self.get_child_count()
	newPart.get_node("FKButton").z_index = 999+newPart.z_index+self.get_child_count()
	newPart.translate(Vector2(64, 0))
	newPart.connect("bodyButton_mouse_isOver", Editor, "_handle_mouseList")
	newPart.connect("FKButton_mouse_isOver", Editor, "_handle_mouseList")

func _process(delta):
	if moving == true:
		_calc_fk()
	if Input.is_action_just_released("mouseLeft") and moving == true:
		moving = false
		$"FKButton".position = Vector2($"bodyPart".texture.get_width(), 0)

func _calc_fk():
	var buttonPos = $"FKButton".get_parent().global_position.distance_to(get_global_mouse_position())
	var mouseP = get_global_mouse_position()
	$"FKButton".position.x = buttonPos
	var distance = $"FKButton".global_position.distance_to(get_global_mouse_position())
	var offset = (get_global_mouse_position() - self.global_position) - buttonOffset
	var r = atan2(offset.y, offset.x)
	self.global_rotation = r
	HUD.partRotate.value = self.global_rotation_degrees

func start_moving():
	buttonOffset = get_global_mouse_position() - $"FKButton".global_position
	moving = true

func _on_bodyButton_mouse_isOver(state):
	emit_signal("bodyButton_mouse_isOver", get_node("bodyButton"), state)

func _on_FKButton_mouse_isOver(state):
	emit_signal("FKButton_mouse_isOver", get_node("FKButton"), state)
