extends Node
@export var ray: RayCast3D
@export var rope: Node3D
@export var cooldown : Timer
@onready var crosshair : TextureRect

@export var rest_length = 2.0
@export var stiffness = 13.0
@export var damping = 1.0

@onready var player: CharacterBody3D = get_parent()

var can_launch = true
var launched = false
var target : Vector3
var is_ui_opened = false


func _ready():
	Playerinteractionsbus.opened_ui.connect(opened_ui)
	#crosshair = get_tree().current_scene.get_node("CanvasLayer2/TextureRect")
	
func _physics_process(delta: float) -> void:
	#if ray.is_colliding():
		#crosshair.change_color(Color.INDIAN_RED)
	#else:
		#crosshair.change_color(Color.WHITE)
		
		
	if can_launch and !is_ui_opened:
		if Input.is_action_just_pressed("use_rope"):
			
			launch()
		if Input.is_action_just_released("use_rope"):
			
			retract()
			
			
		if launched:
			handle_grapple(delta)
	
	update_rope()
		

func launch():
	if ray.is_colliding():
		target = ray.get_collision_point()
		launched = true
		
	
	
func retract():
	if launched:
		launched = false
		can_launch = false
		cooldown.start()
		
	
func handle_grapple(delta: float):
	var target_dir = player.global_position.direction_to(target)
	var target_dist = player.global_position.distance_to(target)
	var displacement = target_dist - rest_length
	
	var force = Vector3.ZERO
	
	if displacement > 0:
		var spring_force_magnitude = stiffness * displacement
		var spring_force = target_dir * spring_force_magnitude
		
		var vel_dot = player.velocity.dot(target_dir)
		var damping = -damping * vel_dot * target_dir
		force = spring_force + damping
		
	
	player.velocity += force * delta

func update_rope():
	if !launched:
		rope.visible = false
		return
		
	rope.visible = true
	
	var dist = player.global_position.distance_to(target)
	
	rope.look_at(target)
	rope.scale = Vector3(1,1, dist)


func _on_grapple_cooldown_timeout() -> void:
	can_launch = true
	cooldown.stop()

func opened_ui(state: bool, _can_move: bool):
	
	if state:
		is_ui_opened = true
	
	else:
		is_ui_opened = false
	
	
