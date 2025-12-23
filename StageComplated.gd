extends Control

onready var button = $Button 

func _ready():
	hide() 
	pause_mode = Node.PAUSE_MODE_PROCESS
	
	if button:
		button.connect("pressed", self, "_on_home_pressed")

func show_victory():
	show()
	get_tree().paused = true

func _on_home_pressed():
	get_tree().paused = false 
	get_tree().change_scene("res://Scene/Main Menu.tscn")
