tool
extends Node2D

# Ukuran tiap kotak grid (ubah sesuai ukuran tile kamu)
export var cell_size := 64

# Ukuran area grid (1720x1080 seperti resolusimu)
export var grid_width := 1920
export var grid_height := 1080

# Warna garis (putih keabu-abuan transparan)
export var grid_color := Color(1, 1, 1, 0.15)

func _ready():
	update()

func _draw():
	# Gambar garis vertikal (pakai <= biar garis terakhir ikut)
	for x in range(0, grid_width + cell_size, cell_size):
		draw_line(Vector2(x, 0), Vector2(x, grid_height), grid_color, 1)

	# Gambar garis horizontal
	for y in range(0, grid_height + cell_size, cell_size):
		draw_line(Vector2(0, y), Vector2(grid_width, y), grid_color, 1)
