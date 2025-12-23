extends Control

var MateriScene = preload("res://Scene/Materi/Materi.tscn")
var AboutScene = preload("res://Scene/About.tscn")
var StageSelectScene = preload("res://Scene/StageSelect.tscn")
var SettingScene = preload("res://Scene/Setting.tscn")

func _ready():
	Global.play_bgm("menu_bgm")
	$Start.connect("pressed", self, "_on_Start_pressed")
	$About.connect("pressed", self, "_on_About_pressed")
	$Materi.connect("pressed", self, "_on_Materi_pressed")
	$Exit.connect("pressed", self, "_on_Exit_pressed")
	$Setting.connect("pressed", self, "_on_Setting_pressed")

func _on_Start_pressed():
	var stageselect_instance = StageSelectScene.instance() 
	add_child(stageselect_instance)                  
	stageselect_instance.show()

func _on_About_pressed():
	var about_instance = AboutScene.instance() 
	add_child(about_instance)                  
	about_instance.show()

func _on_Materi_pressed():
	var materi_instance = MateriScene.instance()
	add_child(materi_instance)
	materi_instance.show()

func _on_Setting_pressed():
	var setting_instance = SettingScene.instance()
	add_child(setting_instance)
	setting_instance.show()

func _on_Exit_pressed():
	get_tree().quit()
