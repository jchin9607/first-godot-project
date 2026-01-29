

extends CharacterBody3D

## Can we move around?
@export var can_move : bool = true
## Are we affected by gravity?
@export var has_gravity : bool = true
## Can we press to jump?
@export var can_jump : bool = true
## Can we hold to run?
@export var can_sprint : bool = false
## Can we press to enter freefly mode (noclip)?
@export var can_freefly : bool = false

@export_group("Speeds")
## Look around rotation speed.
@export var look_speed : float = 0.002
## Normal speed.
@export var base_speed : float = 12
## Speed of jump.
@export var jump_velocity : float = 7
## How fast do we run?
@export var sprint_speed : float = 20
## How fast do we freefly?
@export var freefly_speed : float = 25.0

@export_group("Input Actions")
## Name of Input Action to move Left.
@export var input_left : String = "ui_left"
## Name of Input Action to move Right.
@export var input_right : String = "ui_right"
## Name of Input Action to move Forward.
@export var input_forward : String = "ui_up"
## Name of Input Action to move Backward.
@export var input_back : String = "ui_down"
## Name of Input Action to Jump.
@export var input_jump : String = "ui_accept"
## Name of Input Action to Sprint.
@export var input_sprint : String = "sprint"
## Name of Input Action to toggle freefly mode.
@export var input_freefly : String = "freefly"

var dash_collided = null

var dash_direction = Vector3.ZERO

var mouse_captured : bool = false
var look_rotation : Vector2
var move_speed : float = 0.0
var freeflying : bool = false

var can_wall_jump = true


var can_move_mouse = false

var acceleration : float = 15
var friction : float = 10

var gravity_multiplier = 1.7

var health = 1000


@onready var head: Node3D = $Head
@onready var collider: CollisionShape3D = $Collider
@onready var timer: Timer = $Timer
@onready var cam: Camera3D = $Head/Camera3D
@onready var walljump_cooldown = $WallJumpCooldown

enum State {
	DEFAULT,
	DASH,
	ON_WALL,
	PAUSED,
}

var cur_state = State.DEFAULT

func _ready() -> void:
	
	Playerinteractionsbus.opened_ui.connect(opened_ui)
	check_input_mappings()
	look_rotation.y = rotation.y
	look_rotation.x = head.rotation.x
	capture_mouse()
	
	

func _unhandled_input(event: InputEvent) -> void:
	
	# Mouse capturing
	#if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		#can_move_mouse = false
		#capture_mouse()
	#if Input.is_key_pressed(KEY_ESCAPE):
		#can_move_mouse = true
		#release_mouse()
	
			
		
	# Look around
	if mouse_captured and event is InputEventMouseMotion:
		rotate_look(event.relative)
	
	# Toggle freefly mode
	if can_freefly and Input.is_action_just_pressed(input_freefly):
		if not freeflying:
			enable_freefly()
		else:
			disable_freefly()

func _physics_process(delta: float) -> void:

	# If freeflying, handle freefly and nothing else
	
		
	if cur_state == State.DEFAULT:
		if can_freefly and freeflying:
			var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
			var motion := (head.global_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			motion *= freefly_speed * delta
			move_and_collide(motion)
			return
		
		# Apply gravity to velocity
		if has_gravity:
			if not is_on_floor():
				velocity += get_gravity() * delta * gravity_multiplier

		# Apply jumping
		if can_jump and !is_on_wall_only():
			if Input.is_action_just_pressed(input_jump) and is_on_floor():
				velocity.y = jump_velocity

		# Modify speed based on sprinting
		if can_sprint and Input.is_action_pressed(input_sprint):
				move_speed = sprint_speed
		else:
			move_speed = base_speed

		# Apply desired movement to velocity
		if can_move:
			var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
			var move_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			if move_dir:
				velocity.x = lerpf(velocity.x, move_dir.x * move_speed, acceleration * delta)
				
				velocity.z = lerpf(velocity.z, move_dir.z * move_speed, acceleration * delta)
				
			else:
				velocity.x = lerpf(velocity.x, 0.0, friction * delta)
				velocity.z = lerpf(velocity.z, 0.0, friction * delta)
		else:
			velocity.x = 0
			velocity.y = 0
			
		move_and_slide()
	
		if Input.is_action_just_pressed("dash"):
			if Input.get_vector(input_left, input_right, input_forward, input_back).length() == 0:
				velocity.x = 0
				velocity.z = 0
			dash_direction = Vector3(velocity.x, 0, velocity.z).normalized()  * sprint_speed * 60
			timer.start()
			
			cur_state = State.DASH
			
			
		if is_on_wall_only():
			print(true)
			if Input.is_action_just_pressed(input_jump) and can_wall_jump:
				can_wall_jump = false
				
				walljump_cooldown.start()
				var wall_dir = get_wall_normal()
				var forward = -transform.basis.z
				velocity = (wall_dir + forward * 0.3).normalized() * 60.0
				velocity.y = jump_velocity * 1.3
				move_and_slide()
			
			
				
			
		
	
	
	if cur_state == State.DASH:
		
		if (velocity.x == 0 and velocity.y == 0):
			var forward = -transform.basis.z
			dash_direction = forward.normalized() * sprint_speed * 60
			
		
			
		
		velocity = velocity.move_toward(dash_direction, 100*delta) 
		move_and_slide()
		
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if collision != null and collision.get_collider() is RigidBody3D and dash_collided == null:
				collision.get_collider().take_damage(20)
				dash_collided = collision.get_collider()
		
	
				
		
				
	
	#Exit game
	
	if Input.is_action_just_pressed("quit"):
	
		get_tree().quit()


## Rotate us to look around.
## Base of controller rotates around y (left/right). Head rotates around x (up/down).
## Modifies look_rotation based on rot_input, then resets basis and rotates by look_rotation.
func rotate_look(rot_input : Vector2):
	
	look_rotation.x -= rot_input.y * look_speed
	look_rotation.x = clamp(look_rotation.x, deg_to_rad(-85), deg_to_rad(85))
	look_rotation.y -= rot_input.x * look_speed
	transform.basis = Basis()
	rotate_y(look_rotation.y)
	head.transform.basis = Basis()
	head.rotate_x(look_rotation.x)


func enable_freefly():
	collider.disabled = true
	freeflying = true
	velocity = Vector3.ZERO

func disable_freefly():
	collider.disabled = false
	freeflying = false


func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true


func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false



func check_input_mappings():
	
	if can_move and not InputMap.has_action(input_left):
		push_error("Movement disabled. No InputAction found for input_left: " + input_left)
		can_move = false
	if can_move and not InputMap.has_action(input_right):
		push_error("Movement disabled. No InputAction found for input_right: " + input_right)
		can_move = false
	if can_move and not InputMap.has_action(input_forward):
		push_error("Movement disabled. No InputAction found for input_forward: " + input_forward)
		can_move = false
	if can_move and not InputMap.has_action(input_back):
		push_error("Movement disabled. No InputAction found for input_back: " + input_back)
		can_move = false
	if can_jump and not InputMap.has_action(input_jump):
		push_error("Jumping disabled. No InputAction found for input_jump: " + input_jump)
		can_jump = false
	if can_sprint and not InputMap.has_action(input_sprint):
		push_error("Sprinting disabled. No InputAction found for input_sprint: " + input_sprint)
		can_sprint = false
	if can_freefly and not InputMap.has_action(input_freefly):
		push_error("Freefly disabled. No InputAction found for input_freefly: " + input_freefly)
		can_freefly = false


func _on_timer_timeout() -> void:
	dash_direction = Vector3.ZERO
	
	timer.stop()
	print("timeout")
	cur_state = State.DEFAULT
	dash_collided = null
	pass
	
func opened_ui(state: bool, can_move: bool):
	if state:
		release_mouse()
		if !can_move:
			cur_state = State.PAUSED
	else:
		capture_mouse()
		cur_state = State.DEFAULT


func _on_wall_jump_cooldown_timeout() -> void:
	can_wall_jump = true
	
	walljump_cooldown.stop()
	
func take_damage(amount: int):
	health -= amount
	print(amount)
