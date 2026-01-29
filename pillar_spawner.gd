extends StaticBody3D

@onready var timer = $Timer

var radius = 15.0

func _ready() -> void:
	timer.start()

func _on_timer_timeout() -> void:
	spawn()

func spawn():
	print("spawn")
	
