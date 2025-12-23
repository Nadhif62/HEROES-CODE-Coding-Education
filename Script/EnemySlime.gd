extends StaticBody2D

var is_dead = false
var speed_multiplier = 1.0

onready var sprite = $AnimatedSprite
onready var collision = $CollisionShape2D

func _ready():
	add_to_group("enemy")
	sprite.play("slime_idle")

func set_enemy_speed(new_speed):
	speed_multiplier = new_speed
	sprite.speed_scale = new_speed

func revive():
	is_dead = false
	modulate = Color(1, 1, 1, 1)
	collision.set_deferred("disabled", false)
	sprite.play("slime_idle")

func die():
	if is_dead: return
	
	is_dead = true
	collision.set_deferred("disabled", true)
	
	var tween = Tween.new()
	add_child(tween)
	
	tween.interpolate_property(self, "modulate:a", 1.0, 0.0, 0.5 / float(speed_multiplier), Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	
	yield(tween, "tween_completed")
	get_tree().call_group("finish", "check_enemies")

func attack_target(player_body):
	if is_dead: return
	
	sprite.play("slime_attack")
	
	yield(get_tree().create_timer(0.3 / float(speed_multiplier)), "timeout")
	
	if player_body.has_method("die"):
		player_body.die()
		
	yield(sprite, "animation_finished")
	sprite.play("slime_idle")
	
