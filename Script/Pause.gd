extends Control

# [BARU] Load scene Setting terlebih dahulu
var SettingScene = preload("res://Scene/Setting.tscn") 

onready var stage_pause = $StagePause
onready var btn_back = $BackToGame
onready var btn_setting = $Setting
onready var btn_home = $Home

func _ready():
	visible = false
	# Ini membuat Pause menu DAN anak-anaknya (termasuk Setting nanti) 
	# tetap jalan meskipun game dipause
	pause_mode = Node.PAUSE_MODE_PROCESS 

	btn_back.connect("pressed", self, "_on_BackToGame_pressed")
	btn_setting.connect("pressed", self, "_on_Setting_pressed")
	btn_home.connect("pressed", self, "_on_Home_pressed")

	_load_stage_pause_ui()

func _load_stage_pause_ui():
	var scene = get_tree().get_current_scene()
	var id = scene.get("stage_id")

	if id == null:
		return # Tidak perlu print error kalau tidak ada id, return saja

	var path = "res://Assets/UI/Pause Stage %s.png" % id

	if ResourceLoader.exists(path):
		stage_pause.texture = load(path)

# =============================================================
# LOGIKA TOMBOL
# =============================================================
func open_pause():
	get_tree().paused = true
	visible = true

func close_pause():
	get_tree().paused = false
	visible = false

func _on_BackToGame_pressed():
	close_pause()

func _on_Setting_pressed():
	var setting_instance = SettingScene.instance()
	add_child(setting_instance)

func _on_Home_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://Scene/Main Menu.tscn")
