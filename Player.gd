extends KinematicBody2D

enum {
	IDLE,
	RUN,
	JUMP,
	FALL,
	SLIDE,
}

const GRAVITY = 9.8
const JUMP_SPEED = -GRAVITY * 29
const MAX_VERTICAL = 50 * GRAVITY
const WALK_SPEED = 15
const FRICTION = 1
const MAX_HORIZONTAL = 15 * WALK_SPEED
const STATE2ANIMATION = ["Idling", "Running", "Jumping", "Falling", "Sliding"]

var velocity = Vector2.ZERO
var input_velocity = Vector2.ZERO
var state = IDLE
var input_state = IDLE
var on_floor = false

onready var floor_label = $"../CanvasLayer/floor"
onready var helper_label = $"../CanvasLayer/helper"

func _physics_process(_delta):
	
	if Input.is_action_pressed("fake_restart"):
		get_tree().reload_current_scene()
	
	process_input()
	
	process_input_state()
	
	process_movement()
	
	process_movement_state()
	
	process_animation()
	
	helper_label.text = str(velocity)


func process_input():
	input_velocity = Vector2(0, GRAVITY)
	
	if state == IDLE or state == RUN:
		input_velocity.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		input_velocity.x *= WALK_SPEED
	
	if state != JUMP and state != FALL:
		if on_floor:
			if Input.is_action_just_pressed("ui_select"):
				input_velocity.y = JUMP_SPEED


func process_input_state():
	input_state = IDLE
	if input_velocity.x != 0:
		input_state = RUN
	
	if input_velocity.y < 0:
		input_state = JUMP
	elif not on_floor:
		input_state = FALL


func process_movement():
	if on_floor:
		if velocity.x > 0:
			velocity.x = clamp(velocity.x - FRICTION, 0, MAX_HORIZONTAL)
		elif velocity.x < 0:
			velocity.x = clamp(velocity.x + FRICTION, -MAX_HORIZONTAL, 0)
	velocity.x = clamp(velocity.x + input_velocity.x, -MAX_HORIZONTAL, MAX_HORIZONTAL)
	velocity.y = clamp(velocity.y + input_velocity.y, -MAX_VERTICAL, MAX_VERTICAL)
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	on_floor = is_on_floor()
	if velocity.x != 0:
		$Sprite.flip_h = velocity.x < 0


func process_movement_state():
	if on_floor:
		if velocity.x != 0:
			state = RUN
		else:
			state = IDLE
		floor_label.text = "On floor? Yes"
	else:
		floor_label.text = "On floor? No"
		if velocity.y < 0:
			state = JUMP
		else:
			state = FALL


func process_animation():
	$AnimationPlayer.play(STATE2ANIMATION[state])
