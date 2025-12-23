extends Control

onready var tempat_foto = $TextureRect/ScrollContainer/TextureRect
onready var scroll_container = $TextureRect/ScrollContainer

var folder_gambar = "res://Assets/UI/Materi/"

func _ready():
	scroll_container.scroll_vertical = 0
	
	var nama_file = "materi_" + str(Global.materi_aktif) + ".png"
	var path_lengkap = folder_gambar + nama_file
	
	var dir = Directory.new()
	if dir.file_exists(path_lengkap):
		var gambar = load(path_lengkap)
		tempat_foto.texture = gambar
		
		match Global.materi_aktif:
			2:
				tempat_foto.rect_min_size = Vector2(3380, 4000)
			3:
				tempat_foto.rect_min_size = Vector2(3380, 3000)
			_:
				tempat_foto.rect_min_size = gambar.get_size()
	else:
		print("ERROR: Gambar tidak ditemukan di " + path_lengkap)

func _on_BackButton_pressed():
	queue_free()
