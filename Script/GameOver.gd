extends Control

onready var button = $Button
onready var sfx_gameover = $SFXGameOver

func _ready():
	hide()
	pause_mode = Node.PAUSE_MODE_PROCESS
	
	if button:
		button.connect("pressed", self, "_on_home_pressed")

func show_game_over():
	Global.stop_bgm()
	
	if sfx_gameover:
		sfx_gameover.play()
		
	show()
	get_tree().paused = true

func _on_home_pressed():
	get_tree().paused = false
	Global.change_scene_with_story("res://Scene/Main Menu.tscn", "GameOver")
