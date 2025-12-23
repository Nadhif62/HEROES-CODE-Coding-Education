extends Node

var unlocked_stage = 1
var materi_aktif = 1

var bgm_player = null
var is_bgm_playing = false

var bgm_on = true
var sfx_on  = true
var skip_story_on = false

var bgm_list = {
	"menu_bgm": load("res://Assets/BGM/BGM_Main Menu.mp3"),
}

func _ready():
	bgm_player = AudioStreamPlayer.new()
	bgm_player.bus = "BGM" 
	add_child(bgm_player)

func unlock_next_stage(current_stage):
	if current_stage >= unlocked_stage:
		unlocked_stage = current_stage + 1
		print("Stage ", unlocked_stage, " unlocked")

func play_bgm(name):
	if not bgm_list.has(name): return
	bgm_player.stream = bgm_list[name]
	bgm_player.play()
	is_bgm_playing = true

func stop_bgm():
	bgm_player.stop()
	is_bgm_playing = false

# SETTINGS FUNCTIONS
func set_bgm(status):
	bgm_on = status
	var bus_index = AudioServer.get_bus_index("BGM")
	AudioServer.set_bus_mute(bus_index, not bgm_on)

func set_sfx(status):
	sfx_on = status
	var bus_index = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_mute(bus_index, not sfx_on)

func set_skip_story(status):
	skip_story_on = status
