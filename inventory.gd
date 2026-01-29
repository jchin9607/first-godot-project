extends CanvasLayer

@onready var inventory = $inventory/MarginContainer

#@onready var inside = $inventory/MarginContainer/MarginContainer
@onready var inside = $inventory/MarginContainer/MarginContainer2


#@onready var slot = $inventory/MarginContainer/MarginContainer/Sprite2D
@onready var slot = $inventory/MarginContainer/MarginContainer2/InventorySlot

@onready var invpanel = $inventory/Panel
@onready var insidepanel = $inventory/MarginContainer/Panel

var items = 30
var rows = 5
var columns = items/rows
var margin = 15
var hidden = true
var arr_inv = []




@onready var slot_width = slot.area.texture.get_width() * slot.area.scale.x
@onready var slot_height = slot.area.texture.get_height() * slot.area.scale.y



func _init():
	arr_inv.resize(30)
	arr_inv.fill(0)
	arr_inv[0] = 4
	arr_inv[8] = 8
	arr_inv[15] = 2
	arr_inv[29] = 1
	hide()
	


func _ready():
	SignalBus.switch_items.connect(_on_switch_items)

	await get_tree().process_frame
	
	#var slotswidth = slot_width * columns + margin * (columns - 1)
	#var slotsheight = slot_height * rows + margin * (rows - 1)

	#var xrelmiddle = inside.size.x/2 - slotswidth/2
	#var yrelmiddle = inside.size.y/2  - slotsheight/2
	
	#insidepanel.position.x = xrelmiddle + margin
	#insidepanel.position.y = yrelmiddle + margin
	#
	#insidepanel.size.x = slotswidth 
	#insidepanel.size.y = slotsheight 
	#
	#invpanel.position.x = insidepanel.position.x
	#invpanel.position.y = insidepanel.position.y
	#
	#invpanel.size.x = insidepanel.size.x + margin * 2
	#invpanel.size.y = insidepanel.size.y + margin * 2
	
	for j in range(rows):
		
		for i in range(columns):
			
			if i == 0 and j == 0:
				#slot.area.position.x = xrelmiddle + i * slot_width + margin * i
				#slot.area.position.y = yrelmiddle + j * slot_height + margin * j
				slot.update_label(arr_inv[i+(j * columns)])
				slot.set_index(i + (j* columns))
				
			else:
				var new = slot.duplicate()
				inside.add_child(new)
				#new.area.position.x = xrelmiddle + i * slot_width + margin * i
				#new.area.position.y = yrelmiddle + j * slot_height + margin * j
				
				
				
				new.update_label(arr_inv[i+(j* columns)])
				new.set_index(i + (j* columns))
				
				
		 
	

func _on_switch_items(prev, to):
	var previous_item = arr_inv[prev]
	var to_item = arr_inv[to]
	arr_inv[prev] = to_item
	arr_inv[to] = previous_item
	

	
func _input(event):
	if event.is_action_pressed("inventory"):
		if (hidden):
			show()
			hidden = false
			Playerinteractionsbus.opened_ui.emit(true,true)
			
		else:
			hide()
			hidden = true
			Playerinteractionsbus.opened_ui.emit(false, true)
