extends Control

onready var button = $Button
onready var sfx_victory = $SFXStageCompleted

var completed_stage_name = ""

func _ready():
	hide()
	pause_mode = Node.PAUSE_MODE_PROCESS
	
	if button:
		button.connect("pressed", self, "_on_home_pressed")

func show_victory(stage_name_ref):
	completed_stage_name = stage_name_ref

	Global.stop_bgm()
	if sfx_victory:
		sfx_victory.play()
	
	show()
	get_tree().paused = true

func _on_home_pressed():
	get_tree().paused = false
	var outro_key = completed_stage_name + "_Outro"
	Global.change_scene_with_story("res://Scene/Main Menu.tscn", outro_key)
