extends Control

# --- BAGIAN INI SUDAH DIPERBAIKI (Sesuai Scene Tree kamu) ---
onready var btn_bgm_on = $TombolBGMOn
onready var btn_bgm_off = $TombolBGMOff
onready var btn_sfx_on = $TombolSFXOn
onready var btn_sfx_off = $TombolSFXOff
onready var btn_skip_on = $TombolSkipOn
onready var btn_skip_off = $TombolSkipOff
onready var btn_close = $CloseButton

func _ready():
	# Update tampilan sesuai default Global saat pertama dibuka
	update_tampilan()
	
	btn_bgm_on.connect("pressed", self, "_tekan_bgm_on")
	btn_bgm_off.connect("pressed", self, "_tekan_bgm_off")
	
	btn_sfx_on.connect("pressed", self, "_tekan_sfx_on")
	btn_sfx_off.connect("pressed", self, "_tekan_sfx_off")
	
	btn_skip_on.connect("pressed", self, "_tekan_skip_on")
	btn_skip_off.connect("pressed", self, "_tekan_skip_off")
	
	btn_close.connect("pressed", self, "_tekan_close")

func update_tampilan():
	# Sinkronisasi dengan Global.gd
	# Jika ON, maka tombol ON didisabled (terkunci/terpilih)
	
	btn_bgm_on.disabled = Global.bgm_on
	btn_bgm_off.disabled = not Global.bgm_on
	
	btn_sfx_on.disabled = Global.sfx_on
	btn_sfx_off.disabled = not Global.sfx_on
	
	btn_skip_on.disabled = Global.skip_story_on
	btn_skip_off.disabled = not Global.skip_story_on

# --- FUNGSI PENEKAN TOMBOL ---

func _tekan_bgm_on():
	Global.set_bgm(true)
	update_tampilan()

func _tekan_bgm_off():
	Global.set_bgm(false)
	update_tampilan()

func _tekan_sfx_on():
	Global.set_sfx(true)
	update_tampilan()

func _tekan_sfx_off():
	Global.set_sfx(false)
	update_tampilan()

func _tekan_skip_on():
	Global.set_skip_story(true)
	update_tampilan()

func _tekan_skip_off():
	Global.set_skip_story(false)
	update_tampilan()

func _tekan_close():
	queue_free()
