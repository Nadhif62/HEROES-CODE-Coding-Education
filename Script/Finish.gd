extends Area2D

var is_open = false

func _ready():
	connect("body_entered", self, "_on_body_entered")
	add_to_group("finish")
	reset()

func reset():
	is_open = false
	modulate.a = 0.5

func unlock():
	is_open = true
	modulate.a = 1.0

func check_enemies():
	var enemies = get_tree().get_nodes_in_group("enemy")
	var all_dead = true
	for enemy in enemies:
		if not enemy.get("is_dead"):
			all_dead = false
			break
	if all_dead: unlock()

func _on_body_entered(body):
	if is_open and body.name == "Player":
		body.is_winning_step = true
