extends KinematicBody2D

signal completed

export (String, FILE, "*.tscn") var next_phase_scene
export (bool) var kill_all_to_win = false
export (int) var current_stage_id = 1

var speed = 100
var cell_size = 64
var facing = "left"
var running = false
var speed_multiplier = 1
var start_position
var user_functions = {}
var is_winning_step = false
var is_knockback = false

onready var sprite = $AnimatedSprite
onready var text_edit = get_node("../../UI/TextureRect/TextEdit")
var StageCompletedScene = preload("res://Scene/StageCompleted.tscn")

func _ready():
	add_to_group("finish")
	start_position = position
	_sprite_idle()
	
	if has_node("../../UI"):
		var ui_node = get_node("../../UI")
		if ui_node.has_signal("speed_changed"):
			ui_node.connect("speed_changed", self, "_on_speed_changed")

func run_script():
	if running: return
	
	position = start_position
	facing = "left"
	modulate = Color(1,1,1,1)
	is_winning_step = false
	is_knockback = false
	
	_sprite_idle()
	set_process(true)
	
	get_tree().call_group("enemy", "revive")
	get_tree().call_group("finish", "reset")
	
	running = true
	user_functions.clear()
	
	var raw_lines = text_edit.text.split("\n")
	var lines_to_exec = []
	
	var i = 0
	while i < raw_lines.size():
		var line = String(raw_lines[i]).strip_edges()
		var lower = line.to_lower()
		
		if lower.begins_with("function ") and lower.ends_with("{"):
			var func_name = line.substr(9, line.length()-10).strip_edges().to_lower() + "()"
			var res = _extract_block(raw_lines, i)
			user_functions[func_name] = res[0]
			i = res[1]
		else:
			lines_to_exec.append(raw_lines[i])
			i += 1
			
	var proc = _process_block_lines(lines_to_exec)
	if proc is GDScriptFunctionState:
		yield(proc, "completed")
		
	running = false
	
	if kill_all_to_win:
		_check_remaining_enemies_at_end()
	else:
		_check_surrounding_enemies()
		
	emit_signal("completed")

func _process_block_lines(lines):
	var i = 0
	while i < lines.size():
		if not running: return "BREAK"
		
		while is_knockback: yield(get_tree(), "idle_frame")
		
		var line = String(lines[i]).strip_edges().to_lower()
		
		if line == "" or line.begins_with("#") or line == "}":
			i += 1
			yield(get_tree(), "idle_frame")
			continue
			
		if line == "break":
			return "BREAK"
			
		if line.begins_with("if "):
			var chain_proc = _process_if_chain(lines, i)
			var result = null
			if chain_proc is GDScriptFunctionState:
				result = yield(chain_proc, "completed")
			else:
				result = chain_proc
			
			if result is Array and result[0] == "BREAK":
				return "BREAK"
			
			if result is int:
				i = result
			continue

		if line.begins_with("repeat while"):
			var clean_header = line.split("{")[0].strip_edges()
			var cond_str = clean_header.replace("repeat while", "").strip_edges()
			var res = _extract_block(lines, i)
			var block = res[0]
			i = res[1]
			
			while _evaluate_condition(cond_str):
				if not running: return "BREAK"
				
				var sub = _process_block_lines(block)
				var sub_res = null
				if sub is GDScriptFunctionState:
					sub_res = yield(sub, "completed")
				else:
					sub_res = sub
				
				if sub_res == "BREAK":
					break 
				
				yield(get_tree(), "idle_frame")
			continue
			
		if line.begins_with("repeat(") and line.ends_with("{"):
			var res = _extract_block(lines, i)
			var count = get_number(line, 1)
			var block = res[0]
			i = res[1]
			for _k in range(count):
				if not running: return "BREAK"
				var sub = _process_block_lines(block)
				var sub_res = null
				if sub is GDScriptFunctionState:
					sub_res = yield(sub, "completed")
				else:
					sub_res = sub
					
				if sub_res == "BREAK":
					break
					
				yield(get_tree(), "idle_frame")
			continue
			
		if line.ends_with("()") and user_functions.has(line):
			var sub = _process_block_lines(user_functions[line])
			var sub_res = null
			if sub is GDScriptFunctionState:
				sub_res = yield(sub, "completed")
			else:
				sub_res = sub
			
			if sub_res == "BREAK":
				return "BREAK"
				
			i += 1; continue
			
		var cmd = _exec_command(line)
		if cmd is GDScriptFunctionState: yield(cmd, "completed")
		
		yield(get_tree().create_timer(0.1 / float(speed_multiplier)), "timeout")
		i += 1
		
	yield(get_tree(), "idle_frame")
	return "OK"

func _process_if_chain(lines, start_idx):
	var i = start_idx
	var chain_done = false
	
	while i < lines.size():
		var line = String(lines[i]).strip_edges().to_lower()
		if line == "" or line.begins_with("#"):
			i += 1; continue
		
		var is_if = line.begins_with("if ")
		var is_else_if = line.begins_with("else if ")
		var is_else = line.begins_with("else") and not is_else_if and not is_if
		
		if not (is_if or is_else_if or is_else): break
		
		var res = _extract_block(lines, i)
		var block = res[0]
		var next_i = res[1]
		
		if chain_done:
			i = next_i
			continue
		
		var condition = false
		if is_else:
			condition = true
		else:
			var clean_header = line.split("{")[0].strip_edges()
			var cond_str = ""
			
			if is_else_if:
				cond_str = clean_header.substr(8).strip_edges()
			elif is_if:
				cond_str = clean_header.substr(3).strip_edges()
			
			condition = _evaluate_condition(cond_str)
			
		if condition:
			if block.size() > 0:
				var sub = _process_block_lines(block)
				var sub_res = null
				if sub is GDScriptFunctionState:
					sub_res = yield(sub, "completed")
				else:
					sub_res = sub
				
				if sub_res == "BREAK":
					return ["BREAK", next_i]
					
			chain_done = true
		
		i = next_i
		if is_else: break
		
	yield(get_tree(), "idle_frame")
	return i

func _extract_block(lines, start_idx):
	var block = []
	var idx = start_idx + 1
	var depth = 1
	while idx < lines.size():
		var l = lines[idx].strip_edges()
		var clean_l = l.split("#")[0].strip_edges()
		if clean_l.ends_with("{"): depth += 1
		elif clean_l == "}" or clean_l.begins_with("}"): depth -= 1
		
		if depth == 0: return [block, idx + 1]
		
		block.append(lines[idx])
		idx += 1
	return [block, idx]

func _evaluate_condition(cond_str):
	var or_parts = cond_str.split(" or ")
	for part in or_parts:
		var and_parts = part.split(" and ")
		var and_result = true
		for sub_part in and_parts:
			if not _check_single_condition(sub_part.strip_edges()):
				and_result = false
				break
		if and_result:
			return true
	return false

func _check_single_condition(cond_str):
	if cond_str == "true": return true
	
	var check_dir_name = facing
	var is_enemy_check = "enemy" in cond_str
	var is_clear_check = "clear" in cond_str
	var is_finish_check = "finish" in cond_str
	
	if cond_str.begins_with("front"): check_dir_name = facing
	elif cond_str.begins_with("behind"):
		match facing:
			"front": check_dir_name = "behind"
			"behind": check_dir_name = "front"
			"left": check_dir_name = "right"
			"right": check_dir_name = "left"
	elif cond_str.begins_with("left"):
		match facing:
			"front": check_dir_name = "left"
			"behind": check_dir_name = "right"
			"left": check_dir_name = "behind"
			"right": check_dir_name = "front"
	elif cond_str.begins_with("right"):
		match facing:
			"front": check_dir_name = "right"
			"behind": check_dir_name = "left"
			"left": check_dir_name = "front"
			"right": check_dir_name = "behind"
			
	var check_vector = _get_vector_by_name(check_dir_name)
	var target_pos = position + check_vector
	
	if is_enemy_check:
		var enemies = get_tree().get_nodes_in_group("enemy")
		for enemy in enemies:
			if enemy.get("is_dead"): continue
			if enemy.position.distance_to(target_pos) < 40:
				return true
		return false

	elif is_finish_check:
		var finish_nodes = get_tree().get_nodes_in_group("finish")
		for node in finish_nodes:
			if node != self and node.position.distance_to(target_pos) < 40:
				return true
		return false
		
	elif is_clear_check:
		if test_move(transform, check_vector): return false
		
		var obstacles = get_tree().get_nodes_in_group("obstacle")
		for obs in obstacles:
			if obs.position.distance_to(target_pos) < 40: return false
		
		var enemies = get_tree().get_nodes_in_group("enemy")
		for enemy in enemies:
			if enemy.get("is_dead"): continue
			if enemy.position.distance_to(target_pos) < 40: return false
			
		return true
		
	else:
		if test_move(transform, check_vector): return true
		var obstacles = get_tree().get_nodes_in_group("obstacle")
		for obs in obstacles:
			if obs.position.distance_to(target_pos) < 40: return true
		return false

func _get_vector_by_name(dir_name):
	var check_dist = cell_size * 0.8
	match dir_name:
		"front": return Vector2(0, check_dist)
		"behind": return Vector2(0, -check_dist)
		"left": return Vector2(check_dist, 0)
		"right": return Vector2(-check_dist, 0)
	return Vector2.ZERO

func _get_move_vector():
	match facing:
		"front": return Vector2(0, cell_size)
		"behind": return Vector2(0, -cell_size)
		"left": return Vector2(cell_size, 0)
		"right": return Vector2(-cell_size, 0)
	return Vector2.ZERO

func _move(steps):
	if not running: return
	_sprite_walk()
	
	var vec = _get_move_vector()
	var move_dir = vec.normalized()
	
	for _i in range(steps):
		while is_knockback: 
			_sprite_idle()
			yield(get_tree(), "idle_frame")
		
		if not running: break
		
		var pixels_moved = 0.0
		var target_pixels = cell_size
		
		while pixels_moved < target_pixels:
			if not running: break
			
			var frame_step = speed * speed_multiplier * get_process_delta_time()
			if pixels_moved + frame_step > target_pixels:
				frame_step = target_pixels - pixels_moved
			
			var collision = move_and_collide(move_dir * frame_step)
			
			if collision:
				var collider = collision.collider
				if collider.is_in_group("fire"):
					apply_knockback()
					_sprite_walk()
			
			pixels_moved += frame_step
			yield(get_tree(), "idle_frame")
		
		if not is_knockback:
			position = position.snapped(Vector2(cell_size/2, cell_size/2))
		
		if is_winning_step:
			victory(); return
			
	_sprite_idle()
	yield(get_tree(), "idle_frame")

func _turn(dir_num, steps):
	var dirs = ["front", "right", "behind", "left"]
	for _i in range(steps):
		while is_knockback: yield(get_tree(), "idle_frame")
		if not running: break
		
		var idx = dirs.find(facing)
		var new_idx = (idx + dir_num) % 4
		if new_idx < 0: new_idx += 4
		facing = dirs[new_idx]
		
		_sprite_idle()
		yield(get_tree().create_timer(0.2 / speed_multiplier), "timeout")

func _attack():
	while is_knockback: yield(get_tree(), "idle_frame")
	if not running: return
	
	if sprite.frames.has_animation("knight_attack_" + facing):
		sprite.play("knight_attack_%s" % facing)
	
	yield(_wait(0.5), "timeout")
	
	var vec = _get_move_vector()
	var attack_pos = position + vec
	var enemies = get_tree().get_nodes_in_group("enemy")
	
	for enemy in enemies:
		if enemy.get("is_dead"): continue
		if enemy.position.distance_to(attack_pos) < 40:
			if enemy.has_method("die"):
				enemy.die()
				if kill_all_to_win: _check_remaining_enemies()
			break
			
	_sprite_idle()
	yield(get_tree(), "idle_frame")

func _exec_command(line):
	if line.begins_with("forward"): return _move(get_number(line, 1))
	if line.begins_with("left"): return _turn(-1, get_number(line, 1))
	if line.begins_with("right"): return _turn(1, get_number(line, 1))
	if line.begins_with("attack"): return _attack()
	return null

func _on_speed_changed(new_speed):
	speed_multiplier = new_speed
	sprite.speed_scale = new_speed
	get_tree().call_group("enemy", "set_enemy_speed", new_speed)

func get_number(line, def_val):
	var reg = RegEx.new(); reg.compile("\\((\\d+)\\)")
	var res = reg.search(line); if res: return int(res.get_string(1))
	return def_val

func _wait(t): return get_tree().create_timer(t / float(speed_multiplier))
func _sprite_idle(): if sprite.frames.has_animation("knight_idle_" + facing): sprite.play("knight_idle_" + facing)
func _sprite_walk(): if sprite.frames.has_animation("knight_walk_" + facing): sprite.play("knight_walk_" + facing)

func reset_script():
	running = false
	set_process(false)
	position = start_position
	facing = "left"
	modulate = Color(1,1,1,1)
	_sprite_idle()
	is_knockback = false
	get_tree().call_group("enemy", "revive")
	get_tree().call_group("finish", "reset")

func apply_knockback():
	if is_knockback: return
	is_knockback = true
	_sprite_idle()
	
	var t_flash = Tween.new()
	add_child(t_flash)
	t_flash.interpolate_property(self, "modulate", Color(1,0,0), Color(1,1,1), 0.1)
	t_flash.start()
	
	var vector_mundur = -_get_move_vector()
	if test_move(transform, vector_mundur):
		yield(get_tree().create_timer(0.2), "timeout")
	else:
		var target_pos = position + vector_mundur
		var t_move = Tween.new()
		add_child(t_move)
		t_move.interpolate_property(self, "position", position, target_pos, 0.2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		t_move.start()
		yield(t_move, "tween_completed")
		t_move.queue_free()
		position = position.snapped(Vector2(cell_size/2, cell_size/2))
		
	t_flash.queue_free()
	is_knockback = false

func die():
	running = false
	set_process(false)
	yield(get_tree().create_timer(0.8 / float(speed_multiplier)), "timeout")
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(self, "modulate", Color(1,1,1,1), Color(1,0,0,0), 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_completed")

func victory():
	running = false
	set_process(false)
	_sprite_idle()
	if next_phase_scene and next_phase_scene != "":
		yield(get_tree().create_timer(0.5), "timeout")
		get_tree().change_scene(next_phase_scene)
		return
	Global.unlock_next_stage(current_stage_id)
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(self, "modulate:a", 1.0, 0.0, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_completed")
	var win_instance = StageCompletedScene.instance()
	get_tree().current_scene.add_child(win_instance)
	win_instance.show_victory()

func _check_surrounding_enemies():
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		if enemy.get("is_dead"): continue
		if position.distance_to(enemy.position) < 70:
			if enemy.has_method("attack_target"): enemy.attack_target(self)
			elif enemy.has_method("attack"): enemy.attack()
			return
	var obstacles = get_tree().get_nodes_in_group("obstacle")
	for obs in obstacles:
		if position.distance_to(obs.position) < 50:
			if obs.has_method("trigger_effect"): obs.trigger_effect(self); return

func _check_remaining_enemies():
	var bosses = get_tree().get_nodes_in_group("boss")
	var is_boss_stage = bosses.size() > 0
	var active_enemies = 0
	if is_boss_stage:
		var minions = get_tree().get_nodes_in_group("summoned_minion")
		for m in minions: if not m.get("is_dead"): active_enemies += 1
	else:
		var enemies = get_tree().get_nodes_in_group("enemy")
		for e in enemies: if not e.get("is_dead"): active_enemies += 1
	if active_enemies == 0:
		if next_phase_scene and next_phase_scene != "": victory()
		elif is_boss_stage:
			running = false
			set_process(false)
			_sprite_idle()
			get_tree().call_group("boss", "die")
			yield(get_tree().create_timer(2.0), "timeout")
			victory()

func _check_remaining_enemies_at_end():
	var enemies = get_tree().get_nodes_in_group("enemy")
	for e in enemies: if not e.get("is_dead"): return
