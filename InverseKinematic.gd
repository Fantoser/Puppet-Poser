extends Node
class_name InverseKinematic


export var origin_node : NodePath setget set_origin_path
export var terminus_node : NodePath setget set_terminus_path

export var rotate_terminus : bool

export var joint_range_degrees : float = 90.0
export var precision_cycles : int = 32

var origin : Node2D
var terminus : Node2D

var ik_chain : Array

var is_ready : bool = false
var config_warning : String

func _ready():
	is_ready = true
	set_origin_path(origin_node)
	set_terminus_path(terminus_node)


func reach_toward(coordinate : Vector2):
	var _distance = 99999999.99
	for cycle in precision_cycles:
		_distance = cycle(coordinate)


func cycle(target_position : Vector2) -> float:
	for link in ik_chain:
		if link == terminus:
			if rotate_terminus:
				link.look_at(target_position)
			continue
		var limit = deg2rad(joint_range_degrees)
		var alpha_vector = terminus.global_position - link.global_position
		var goal_vector = target_position - link.global_position
		var rotation_amount = alpha_vector.angle_to(goal_vector)
		if abs(rotation_amount) > limit:
			rotation_amount = limit * sign(rotation_amount)
		link.rotation += rotation_amount
		if abs(link.rotation) > limit:
			link.rotation = limit * sign(link.rotation)
	return (target_position - terminus.global_position).length()


func trace_ik_chain():
	if not origin or not terminus:
		ik_chain.clear()
		return
	if origin == terminus:
		ik_chain.clear()
		return
	if not origin.is_a_parent_of(terminus):
		config_warning = "Terminus must be a direct descendant of Origin."
		ik_chain.clear()
		return
	var chain = []
	var link = terminus
	while not link == origin:
		chain.append(link)
		link = link.get_parent()
	chain.append(origin)
	for currentLink in chain:
		if not currentLink is Node2D:
			config_warning = "Invalid Node type in IK chain."
			ik_chain.clear()
			return
	ik_chain = chain
	config_warning = ""


func set_origin_path(path):
	origin_node = path
	if not is_ready:
		return
	var first_link = get_node(origin_node)
	if not first_link is Node2D:
		config_warning = "Origin and Terminus must both be Node2D."
		return
	origin = first_link
	trace_ik_chain()

func set_terminus_path(path):
	terminus_node = path
	if not is_ready:
		return
	var last_link = get_node(terminus_node)
	if not last_link is Node2D:
		config_warning = "Origin and Terminus must both be Node2D."
		return
	terminus = last_link
	trace_ik_chain()




func _get_configuration_warning():
	return config_warning
