extends StaticBody2D

var speed_multiplier = 1.0
onready var sprite = $AnimatedSprite

func _ready():
	sprite.play("Fire")
	
func set_fire_speed(new_speed):
	speed_multiplier = new_speed
	sprite.speed_scale = new_speed
	
func _on_body_entered(body):
	if body.has_method("apply_knockback"):
		body.apply_knockback()
