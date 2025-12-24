extends Control

var SettingScene = preload("res://Scene/Setting.tscn")
var GameOverScene = preload("res://Scene/GameOver.tscn")

onready var stage_pause = $StagePause
onready var btn_back = $BackToGame
onready var btn_setting = $Setting
onready var btn_home = $Home
onready var sfx_click = $SFXClick

func _ready():
	visible = false
	pause_mode = Node.PAUSE_MODE_PROCESS

	btn_back.connect("pressed", self, "_on_BackToGame_pressed")
	btn_setting.connect("pressed", self, "_on_Setting_pressed")
	btn_home.connect("pressed", self, "_on_Home_pressed")

	_load_stage_pause_ui()

func _load_stage_pause_ui():
	var scene = get_tree().get_current_scene()
	var id = scene.get("stage_id")

	if id == null:
		return

	var path = "res://Assets/UI/Pause Stage %s.png" % id

	if ResourceLoader.exists(path):
		stage_pause.texture = load(path)

func open_pause():
	sfx_click.play()
	get_tree().paused = true
	visible = true

func close_pause():
	get_tree().paused = false
	visible = false

func _on_BackToGame_pressed():
	sfx_click.play()
	close_pause()

func _on_Setting_pressed():
	sfx_click.play()
	var setting_instance = SettingScene.instance()
	add_child(setting_instance)

func _on_Home_pressed():
	sfx_click.play()
	visible = false
	
	var game_over_instance = GameOverScene.instance()
	get_tree().current_scene.add_child(game_over_instance)
	game_over_instance.show_game_over()
