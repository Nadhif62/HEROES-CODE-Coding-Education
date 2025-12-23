extends Control

onready var close_button = $CloseButton 
onready var sfx_click = $SFXClick

func _ready():
	if close_button:
		close_button.connect("pressed", self, "_on_close_pressed")
	else:
		print("Tombol Close tidak ditemukan!")

func _on_close_pressed():
	sfx_click.play()
	yield(get_tree().create_timer(0.2), "timeout")
	queue_free()
