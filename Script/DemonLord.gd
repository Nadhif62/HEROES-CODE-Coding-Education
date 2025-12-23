extends StaticBody2D

var is_dead = false
var has_summoned = false

onready var sprite = $AnimatedSprite
onready var collision = $CollisionShape2D

func _ready():
	add_to_group("enemy")
	add_to_group("boss")
	start_summon_sequence(false)

func start_summon_sequence(is_instant = false):
	if has_summoned: return
	has_summoned = true
	
	if is_instant:
		sprite.play("demonlord_idle")
		get_tree().call_group("summoned_minion", "spawn_instant")
	else:
		sprite.play("demonlord_summon")
		yield(get_tree().create_timer(0.5), "timeout")
		
		if is_dead: return
		
		get_tree().call_group("summoned_minion", "spawn_fade_in")
		
		yield(sprite, "animation_finished")
		
		if not is_dead:
			sprite.play("demonlord_idle")

func on_pillar_destroyed():
	if is_dead: return
	sprite.play("demonlord_damaged")
	yield(sprite, "animation_finished")
	if not is_dead:
		sprite.play("demonlord_idle")

func attack_target(_player):
	pass

func die():
	if is_dead: return
	is_dead = true
	
	if is_in_group("enemy"):
		remove_from_group("enemy")
	
	collision.set_deferred("disabled", true)
	
	sprite.play("demonlord_damaged")
	yield(sprite, "animation_finished")
	
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(self, "modulate:a", 1.0, 0.0, 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_completed")
	queue_free()

func revive():
	is_dead = false
	has_summoned = false
	
	if not is_in_group("enemy"):
		add_to_group("enemy")
		
	collision.set_deferred("disabled", false)
	
	modulate = Color(1,1,1,1)
	start_summon_sequence(true)

func set_enemy_speed(val):
	sprite.speed_scale = val
