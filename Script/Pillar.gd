extends StaticBody2D

var is_dead = false
onready var sprite = $Sprite
onready var collision = $CollisionShape2D

func _ready():
	add_to_group("summoned_minion")
	add_to_group("enemy")
	add_to_group("pillar")
	
	modulate.a = 0.0
	collision.set_deferred("disabled", true)

func spawn_fade_in():
	is_dead = false
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(self, "modulate:a", 0.0, 1.0, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_completed")
	
	collision.set_deferred("disabled", false)
	tween.queue_free()

func spawn_instant():
	is_dead = false
	modulate.a = 1.0
	collision.set_deferred("disabled", false)

func die():
	if is_dead: return
	is_dead = true
	
	collision.set_deferred("disabled", true)
	get_tree().call_group("boss", "on_pillar_destroyed")
	
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(self, "modulate:a", 1.0, 0.0, 0.5)
	tween.start()
	yield(tween, "tween_completed")

func revive():
	spawn_instant()

func attack_target(_player):
	pass
