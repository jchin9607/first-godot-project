extends StaticBody3D

@onready var timer = $Timer
const skeleton = preload("res://models/skeleton/skeleton.tscn")

var radius = 15.0

static var amount = 0
var limit = 8

func _ready() -> void:
	timer.start()

func _on_timer_timeout() -> void:
	if (amount >= limit): return
	spawn()
	

func spawn():
	var skel = skeleton.instantiate()
	var rand = randi() % 2
	if rand == 1:
		skel.position.x = radius * randf() 
	else:
		skel.position.z = radius * randf()
		
	rand = randi() % 2
	if rand == 1:
		skel.position = skel.position * Vector3(-1, -1, -1)
	
		
	add_sibling(skel)
	amount += 1
	
