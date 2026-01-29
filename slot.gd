extends Sprite2D

@onready var area = $Area2D
@onready var label = $Label


var index : int
var hovered = false
var holding = false
static var carrying = null
static var slot_mouse_over : Sprite2D
static var prev_slot_for_index : Sprite2D



func _ready():
	area.connect("mouse_entered", mouse_entered)
	area.connect("mouse_exited", mouse_exited)
	area.connect("input_event", input_event)
	set_process(false)
	#print("v")
	#print_orphan_nodes()
	#print("^")

func mouse_entered():
	self_modulate.a = 0.5
	hovered = true
	slot_mouse_over = self
	
	
	
func mouse_exited():
	self_modulate.a = 1
	hovered = false
	slot_mouse_over = null
	
	if carrying == null or carrying.text != label.text:
		set_process(false)
		#print("falsed")
	
func update_label(num):
	label.text =  str(num)
	
	if num == 0:
		label.hide()
	else: 
		label.show()

func input_event(_viewport, event, _shape_idx):
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		#if event.pressed and carrying == null:
			#holding = true
	#
		#else:
			#holding = false
	#else:
		#holding = false
		
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and carrying == null:
		holding = true
		
		if carrying == null and label.text != "0":
			carrying = Label.new()
			carrying.text = label.text
			carrying.z_as_relative = 100
			prev_slot_for_index = self
			var ui_layer = get_parent()
			ui_layer.add_child(carrying)
			set_process(true)
			
	else:
		holding = false
		
	
	
func _process(_delta):
	
	area.global_position = global_position

	
	self_modulate.a = 0.5
	var mouse_pos := get_viewport().get_mouse_position()
	if carrying != null:
		carrying.position.x = mouse_pos.x
		carrying.position.y = mouse_pos.y - 40
		
	
	
	#print(str(mouse_pos.x) + ", " + str(mouse_pos.y))
	#print(holding)
	
	if Input.is_action_just_released("click"):
		if slot_mouse_over != null and carrying != null:
			var other_index = slot_mouse_over.index
			_on_release_switch_items(prev_slot_for_index.index, other_index)
			
		self_modulate.a = 1
		carrying.queue_free()
		carrying = null
		prev_slot_for_index = null
		#print("falsed")
		
		
		set_process(false)
		
	
	
func set_index(num):
	index = num
	
func _on_release_switch_items(prev, to):
	var prev_text = int(label.text)
	update_label(int(slot_mouse_over.label.text))
	slot_mouse_over.update_label(prev_text)
	
	SignalBus.switch_items.emit(prev, to)
	
