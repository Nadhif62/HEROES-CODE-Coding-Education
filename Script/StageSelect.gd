extends Control

onready var stage_buttons = [
	$Stage1,
	$Stage2,
	$Stage3,
	$Stage4,
	$Stage5
]

onready var locked_icons = [
	$"Stage2 Locked",
	$"Stage3 Locked",
	$"Stage4 Locked",
	$"Stage5 Locked"
]

onready var back_button = $Back
onready var sfx_click = $SFXClick

func _ready():
	update_stage_lock()
	connect_stage_buttons()
	connect_back_button()

func update_stage_lock():
	for i in range(stage_buttons.size()):
		if i + 1 <= Global.unlocked_stage:
			stage_buttons[i].visible = true
			if i > 0:
				locked_icons[i - 1].visible = false
		else:
			stage_buttons[i].visible = false
			if i > 0:
				locked_icons[i - 1].visible = true

func connect_back_button():
	if back_button:
		if not back_button.is_connected("pressed", self, "_on_back_button_pressed"):
			back_button.connect("pressed", self, "_on_back_button_pressed")
	else:
		print("Node Back tidak ditemukan!")
		
func connect_stage_buttons():
	for i in range(stage_buttons.size()):
		if not stage_buttons[i].is_connected("pressed", self, "_on_stage_button_pressed"):
			stage_buttons[i].connect("pressed", self, "_on_stage_button_pressed", [i + 1])

func _on_stage_button_pressed(stage_number):
	sfx_click.play()
	
	var path = ""
	
	if stage_number == 4:
		path = "res://Scene/Stage/Stage4Phase1.tscn"
	elif stage_number == 5:
		path = "res://Scene/Stage/Stage5Phase1.tscn"
	else:
		path = "res://Scene/Stage/Stage%d.tscn" % stage_number
	
	Global.stop_bgm()
	
	yield(get_tree().create_timer(0.2), "timeout")
	
	if ResourceLoader.exists(path):
		Global.change_scene_with_story(path)
	else:
		print("Scene tidak ditemukan: %s" % path)

func _on_back_button_pressed():
	sfx_click.play()
	yield(get_tree().create_timer(0.2), "timeout")
	queue_free()
