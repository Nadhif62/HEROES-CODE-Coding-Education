extends Control

onready var tempat_foto = $TextureRect/ScrollContainer/TextureRect
onready var scroll_container = $TextureRect/ScrollContainer
onready var sfx_click = $SFXClick

var folder_gambar = "res://Assets/UI/Materi/"

func _ready():
	scroll_container.scroll_vertical = 0
	
	var nama_file = "materi_" + str(Global.materi_aktif) + ".png"
	var path_lengkap = folder_gambar + nama_file

	if ResourceLoader.exists(path_lengkap):
		var gambar = load(path_lengkap)
		tempat_foto.texture = gambar
		tempat_foto.rect_min_size = gambar.get_size()
	else:
		print("ERROR: Gambar tidak ditemukan di " + path_lengkap)
func _on_BackButton_pressed():
	sfx_click.play()
	yield(get_tree().create_timer(0.2), "timeout")
	queue_free()
