extends CanvasLayer


@onready var textboxcontainer = $MarginContainer
@onready var label = $MarginContainer/MarginContainer/HBoxContainer/Label

enum State {
	IDLE,
	READY,
	READING,
	FINISHED
}

var current_state = State.IDLE

var tween : Tween

var messages = [
	"hello world, lorem ipsum, lorem ipsum, this is crazy , this is a textbox",
	"This is one two three four five six seven",
	"This is the start of a great rpg.....",
	"or a combat sim idk",
	"I can add a lot more stuff here too"
	]
	
var current = 0

func _ready():
	
	hidetextbox()
	
	#addtext("hello world, lorem ipsum, lorem ipsum, this is crazy , this is a textbox")
	
func _process(_delta):
	
	match current_state:
		State.IDLE:
			hidetextbox()
			
			if Input.is_action_just_released("interact"):
				changestate(State.READY)
		State.READY:
			
			if current == len(messages):
				
				current = 0
				changestate(State.IDLE)
			else: 
				addtext(messages[current])
				
			
		State.READING:
			if Input.is_action_just_released("interact"):
				label.visible_ratio = 1
				tween.kill()
				changestate(State.FINISHED)
				
				
		
		State.FINISHED:
			if Input.is_action_just_released("interact"):
				current += 1
				changestate(State.READY)
	
func hidetextbox():
	label.text = ""
	hide()

func showtextbox():
	show()
	
func addtext(message):
	label.text = message
	label.visible_ratio = 0
	showtextbox()
	changestate(State.READING)
	tween = create_tween()
	tween.connect("finished", _on_tween_finished)
	tween.play()
	tween.tween_property(label, "visible_ratio", 1.0, len(message) * 0.03)
	

func changestate(nextstate):
	current_state = nextstate
	match current_state:
		State.READY:
			print("READY")
		State.READING:
			print("READING")
		State.FINISHED:
			print("FINISHED")
	
func _on_tween_finished():
	tween.kill()
	changestate(State.FINISHED)
	print("your tween finished")
