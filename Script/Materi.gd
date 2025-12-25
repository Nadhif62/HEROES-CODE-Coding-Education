extends Control

onready var scroll_container = $TextureRect/ScrollContainer
onready var vbox_container = $TextureRect/ScrollContainer/VBoxContainer
onready var close_button = $CloseButton 
onready var sfx_click = $SFXClick

var scene_isi_materi = preload("res://Scene/Materi/IsiMateri.tscn")

func _ready():
	var scrollbar = scroll_container.get_v_scrollbar()
	
	var style_batang = StyleBoxFlat.new()
	style_batang.bg_color = Color("8B4513")
	style_batang.set_expand_margin_all(8)
	style_batang.set_corner_radius_all(6)
	
	var style_jalur = StyleBoxFlat.new()
	style_jalur.bg_color = Color(0.2, 0.1, 0.05, 0.6)
	style_jalur.content_margin_right = 16
	style_jalur.set_corner_radius_all(6)

	scrollbar.add_stylebox_override("grabber", style_batang)
	scrollbar.add_stylebox_override("grabber_highlight", style_batang)
	scrollbar.add_stylebox_override("grabber_pressed", style_batang)
	scrollbar.add_stylebox_override("scroll", style_jalur)
	
	for i in range(9):
		var nama_tombol = "MateriBtn" + str(i)
		
		if vbox_container.has_node(nama_tombol):
			vbox_container.get_node(nama_tombol).connect("pressed", self, "buka_materi", [i])

	if close_button:
		close_button.connect("pressed", self, "_on_close_pressed")

func buka_materi(nomor):
	sfx_click.play()
	Global.materi_aktif = nomor
	var popup = scene_isi_materi.instance()
	add_child(popup)

func _on_close_pressed():
	sfx_click.play()
	yield(get_tree().create_timer(0.2), "timeout")
	queue_free()
