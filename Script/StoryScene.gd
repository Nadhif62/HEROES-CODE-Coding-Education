extends Control

onready var text_label = $VBoxContainer/RichTextLabel 
onready var anim_player = $AnimationPlayer
onready var sfx_player = $SFXPlayer

# Atur kecepatan suara di sini (0.1 = cepat, 0.2 = sedang, 0.5 = lambat)
export var sfx_interval = 0.1 
var sfx_timer = 0.0

var dialogue_queue = []
var index = 0
var state = "IDLE"

func _ready():
	var key = Global.current_story_key
	if Global.story_database.has(key):
		dialogue_queue = Global.story_database[key]
		load_dialogue()
	else:
		finish_story()

func _process(delta):
	# Logic Looping Suara Manual
	if state == "TYPING":
		sfx_timer -= delta
		if sfx_timer <= 0:
			sfx_player.play()
			sfx_timer = sfx_interval

	# Input Logic
	if Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(BUTTON_LEFT):
		match state:
			"TYPING":
				sfx_player.stop() # Matikan suara sisa
				anim_player.seek(anim_player.current_animation_length, true)
				state = "WAITING"
			"WAITING":
				anim_player.play("fade_out")
				state = "FADING"

func load_dialogue():
	if index < dialogue_queue.size():
		var line = dialogue_queue[index]
		
		text_label.bbcode_text = "[center]" + line["text"] + "[/center]"
		
		text_label.percent_visible = 0
		text_label.modulate.a = 1.0 
		
		var anim_name = line.get("anim", "text_appear")
		if anim_player.has_animation(anim_name):
			anim_player.play(anim_name)
			# Reset timer biar langsung bunyi pas mulai
			sfx_timer = 0.0 
			state = "TYPING"
		else:
			text_label.percent_visible = 1
			state = "WAITING"
	else:
		finish_story()

func finish_story():
	var target = Global.next_scene_path_buffer
	if target != "":
		get_tree().change_scene(target)
	else:
		get_tree().change_scene("res://Scene/Main Menu.tscn")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "text_appear":
		state = "WAITING"
	elif anim_name == "fade_out":
		index += 1
		load_dialogue()
