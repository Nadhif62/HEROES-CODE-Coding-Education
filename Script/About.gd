extends Control

onready var close_button = $CloseButton 

func _ready():
	if close_button:
		close_button.connect("pressed", self, "_on_close_pressed")
	else:
		print("Tombol Close tidak ditemukan!")

func _on_close_pressed():
	queue_free()
