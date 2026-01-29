extends Control

@onready var area = $TextureRect
@onready var label = $TextureRect/Label

var index : int
var hovered = false
var holding = false
static var carrying : Label
static var slot_mouse_over : Control
static var prev_slot_for_index : Control
static var carrying_canvas_layer = null



func _ready():
	area.connect("mouse_entered", mouse_entered)
	area.connect("mouse_exited", mouse_exited)
	area.connect("gui_input", gui_input)
	set_process(false)
	#print(size)
	#print("v")
	#print_orphan_nodes()
	#print("^")

func mouse_entered():
	area.self_modulate.a = 0.5
	hovered = true
	slot_mouse_over = self
	
	
	
func mouse_exited():
	area.self_modulate.a = 1
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

func gui_input(event):
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
			carrying_canvas_layer = CanvasLayer.new()
			carrying_canvas_layer.layer = 100  # High layer to be on top
			get_tree().root.add_child(carrying_canvas_layer)
			
			carrying = Label.new()
			carrying.text = label.text
			carrying.z_index = 100
			prev_slot_for_index = self
			carrying_canvas_layer.add_child(carrying)
			carrying.top_level = true
			set_process(true)
	else:
		holding = false
		
	
	
func _process(_delta):
	
	

	
	self_modulate.a = 0.5
	var mouse_pos : Vector2 =  get_viewport().get_mouse_position()
	if carrying != null:
		carrying.position.x = mouse_pos.x
		carrying.position.y = mouse_pos.y - 40
		
	
	
	
	
	if Input.is_action_just_released("click"):
		if slot_mouse_over != null and carrying != null:
			var other_index = slot_mouse_over.index
			_on_release_switch_items(prev_slot_for_index.index, other_index)
			
		if carrying_canvas_layer != null:
			carrying_canvas_layer.queue_free()
			carrying_canvas_layer = null
			
		self_modulate.a = 1
		carrying.queue_free()
		carrying = null
		prev_slot_for_index = null
		
		
		
		set_process(false)
		
 
	
func set_index(num):
	index = num
	
func _on_release_switch_items(prev, to):
	var prev_text = int(label.text)
	update_label(int(slot_mouse_over.label.text))
	slot_mouse_over.update_label(prev_text)
	
	SignalBus.switch_items.emit(prev, to)
	
