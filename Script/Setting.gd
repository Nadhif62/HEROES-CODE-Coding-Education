extends Control

onready var btn_bgm_on = $TombolBGMOn
onready var btn_bgm_off = $TombolBGMOff
onready var btn_sfx_on = $TombolSFXOn
onready var btn_sfx_off = $TombolSFXOff
onready var btn_skip_on = $TombolSkipOn
onready var btn_skip_off = $TombolSkipOff
onready var btn_close = $CloseButton
onready var sfx_click = $SFXClick

func _ready():
	update_tampilan()
	
	btn_bgm_on.connect("pressed", self, "_tekan_bgm_on")
	btn_bgm_off.connect("pressed", self, "_tekan_bgm_off")
	
	btn_sfx_on.connect("pressed", self, "_tekan_sfx_on")
	btn_sfx_off.connect("pressed", self, "_tekan_sfx_off")
	
	btn_skip_on.connect("pressed", self, "_tekan_skip_on")
	btn_skip_off.connect("pressed", self, "_tekan_skip_off")
	
	btn_close.connect("pressed", self, "_tekan_close")

func update_tampilan():
	btn_bgm_on.disabled = Global.bgm_on
	btn_bgm_off.disabled = not Global.bgm_on
	
	btn_sfx_on.disabled = Global.sfx_on
	btn_sfx_off.disabled = not Global.sfx_on
	
	btn_skip_on.disabled = Global.skip_story_on
	btn_skip_off.disabled = not Global.skip_story_on

func _tekan_bgm_on():
	sfx_click.play()
	Global.set_bgm(true)
	update_tampilan()

func _tekan_bgm_off():
	sfx_click.play()
	Global.set_bgm(false)
	update_tampilan()

func _tekan_sfx_on():
	sfx_click.play()
	Global.set_sfx(true)
	update_tampilan()

func _tekan_sfx_off():
	sfx_click.play()
	Global.set_sfx(false)
	update_tampilan()

func _tekan_skip_on():
	sfx_click.play()
	Global.set_skip_story(true)
	update_tampilan()

func _tekan_skip_off():
	sfx_click.play()
	Global.set_skip_story(false)
	update_tampilan()

func _tekan_close():
	sfx_click.play()
	yield(get_tree().create_timer(0.2), "timeout")
	queue_free()
