class_name Player
extends KinematicBody

export var ag_transition = "parameters/ag_transition/current"
export var gw_transition = "parameters/gw_transition/current"
var direction = Vector3.FORWARD
var angular_acceleration = 7
#=======SPECIAL MOVES==========
var input_sequence := ["up", "down", "left", "right"]
var current_input_index := 0
#==============================

onready var cam = get_node("/root/LevelNode/Localcam/h_rotate/Plr_reference")
onready var level_node = get_node("LevelNode")
func some_function():
	var camera_name = "h_rotate"
	var camera_path = "/root/Localcam/" + camera_name
	var camera_global_transform = level_node.get_node(camera_path).global_transform
	var h_rot = camera_global_transform.basis.get_euler().y


#==============================
export var walk_speed := 1.5
export var run_speed := 5.0
export var gravity := -20.0
export var h_accel := 35.00
export var v_accel := 35.00
export var jump_power := 15.0
export var max_jumps := 2
export var jump_delay := 0.1
export var water_multiplier := 0.25 

var movement_vector := Vector3.ZERO
var jump_amount := max_jumps
var jump_timer := Timer.new()
var in_water := false

func _ready():
	add_child(jump_timer)
	jump_timer.one_shot = true
	jump_timer.connect("timeout", self, "jump_timer_timeout")

	direction = Vector3.BACK.rotated(Vector3.UP, cam.global_transform.basis.get_euler().y)

#=======LOOK AT========
func _process(delta):
	set_target_pos_in_globals()
#=======LOOK AT========

func _input(event):
#==========MAPEAMENTO CONTROLE============
	if Input.get_connected_joypads().size() > 0:

		for i in range(26):
			if Input.is_joy_button_pressed(0,i):
				print(str(i) + Input.get_joy_button_string(i))


#=======SPECIAL MOVES==========
	if event.is_action_pressed("ui_up"):
		check_input("up")
	elif event.is_action_pressed("ui_down"):
		check_input("down")
	elif event.is_action_pressed("ui_left"):
		check_input("left")
	elif event.is_action_pressed("ui_right"):
		check_input("right")
#=============================


func _physics_process(delta) -> void:
	
	var h_rot = cam.global_transform.basis.get_euler().y
	
	var modifier := 1.0
	if in_water:
		modifier *= water_multiplier

			
#	MOVIMENTO HORIZONTAL
	var horizontal_input := Vector3.ZERO
	horizontal_input.x = -Input.get_joy_axis(0 , JOY_AXIS_0)
	horizontal_input.z = -Input.get_joy_axis(0, JOY_AXIS_1)
#	horizontal_input.x = Input.get_axis("rgt", "lft")
#	horizontal_input.z = Input.get_axis("dwn", "up")
	horizontal_input = horizontal_input.limit_length(1.0)
	horizontal_input *= run_speed if Input.is_action_pressed("run") else walk_speed
	horizontal_input.y = movement_vector.y
	movement_vector = movement_vector.move_toward(horizontal_input, h_accel * delta)
	
	direction = direction.rotated(Vector3.UP, h_rot).normalized()
	
	$Mesh.rotation.y = lerp_angle($Mesh.rotation.y, atan2(direction.x, direction.z), delta * angular_acceleration)

	
#	MOVIMENTO VERTICAL
	movement_vector.y = move_toward(movement_vector.y, gravity, v_accel * delta)
	if is_on_floor():
		jump_amount = max_jumps
		jump_timer.stop()
	elif jump_timer.is_stopped() and jump_amount == max_jumps:
		jump_timer.start(jump_delay)

	
	if Input.is_action_just_pressed("jump") and jump_amount > 0:
		movement_vector.y = jump_power
		jump_amount -= 1
		jump_timer.stop()
		if jump_amount == 1:
			print("pulo 1")
		else:
			print("pulo 2")

#	MOVER
	movement_vector = move_and_slide(movement_vector * modifier, Vector3.UP)
	movement_vector /= modifier

	

#_____________________________________________

	$Status/Label.text = "direction : " + String(movement_vector)
	$Status/Label2.text = "direction.length() : " + String(movement_vector.length())
	$Status/Label3.text = "velocity : " + String(movement_vector)
	$Status/Label4.text = "velocity.length() : " + String(movement_vector.length())
	$Status/Label5.text = "$RayCast_floor : " + String($RayCast.is_colliding())
	$Status/Label6.text = "RayCast2 : " + String($Mesh/RayCast2.is_colliding())
	$Status/Label7.text = "velocity.length() : " + String(movement_vector.y)

#_____________________________________________

func jump_timer_timeout():
	jump_amount -= 1

func swimming():
	gw_transition = 1
	print("water")
	
#=======LOOK AT====
func set_target_pos_in_globals():
	$"/root/Globals".target_pos = global_transform.origin
#=======LOOK AT====
	
#=======SPECIAL MOVES==========
func check_input(input):
	if input == input_sequence[current_input_index]:
		current_input_index += 1
		if current_input_index >= input_sequence.size():
			print("special move")
			current_input_index = 0
	else:
		current_input_index = 0
#==============================
