extends "res://entities/units/player/player.gd"

func take_damage(value: int, args: TakeDamageArgs) -> Array:
	
	# 1. Store old health to compare later
	var old_hp = current_stats.health
	
	# 2. Call the ORIGINAL function (using the dot operator)
	# This ensures the game calculates dodge, armor, and invincibility correctly.
	# We capture the result because the original function returns an Array.
	var result = .take_damage(value, args)
	
	# 3. Check new health
	var new_hp = current_stats.health
	
	# 4. Mod Logic: Print to console if health dropped
	if new_hp < old_hp:
		# Using Godot's print format for cleaner logs
		print("DEBUG: Player took damage! HP: %s -> %s" % [str(old_hp), str(new_hp)])
	
	# 5. Mod Logic: Show pause menu if HP is 2 (or 1) but not dead
	if new_hp <= 2 and new_hp > 0:
		print("DEBUG: CRITICAL HEALTH DETECTED! Showing pause menu.")
		
		# Method 1: Try to access the main node's pause menu directly
		print("DEBUG: Method 1 - Trying direct UI/PauseMenu access")
		var main_node = get_tree().get_current_scene()
		if main_node and main_node.has_node("UI/PauseMenu"):
			var pause_menu = main_node.get_node("UI/PauseMenu")
			if pause_menu and pause_menu.has_method("pause") and pause_menu.enabled:
				print("DEBUG: Method 1 SUCCESS - Direct pause menu access")
				pause_menu.pause(0)
				return result
			elif pause_menu and not pause_menu.enabled:
				print("DEBUG: Pause menu disabled, enabling and pausing")
				pause_menu.enabled = true
				pause_menu.pause(0)
				return result
			else:
				print("DEBUG: Method 1 FAILED - Pause menu not accessible")
		else:
			print("DEBUG: Method 1 FAILED - UI/PauseMenu node not found")
		
		# Method 2: Access through Main class variable (_pause_menu)
		print("DEBUG: Method 2 - Trying _pause_menu variable access")
		if main_node and main_node.get("_pause_menu"):
			var pause_menu = main_node._pause_menu
			if pause_menu and pause_menu.enabled:
				print("DEBUG: Method 2 SUCCESS - _pause_menu variable access")
				pause_menu.pause(0)
				return result
			else:
				print("DEBUG: Method 2 FAILED - _pause_menu not accessible")
		else:
			print("DEBUG: Method 2 FAILED - _pause_menu variable not found")
		
		# Method 3: Emit the ui_pause input action (like pressing ESC)
		print("DEBUG: Method 3 - Trying ui_pause input action")
		var pause_event = InputEventAction.new()
		pause_event.action = "ui_pause"
		pause_event.pressed = true
		Input.parse_input_event(pause_event)
		
		# If all methods fail, fallback to simple pause
		if not get_tree().paused:
			print("DEBUG: Method 4 - All methods failed, using simple pause")
			get_tree().paused = true
		else:
			print("DEBUG: Game was paused by input action method")
		
	# 6. Return the original result so the game doesn't break
	return result
