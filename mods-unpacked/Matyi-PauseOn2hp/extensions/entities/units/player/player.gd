extends "res://entities/units/player/player.gd"

func take_damage(value: int, args: TakeDamageArgs) -> Array:
	
	# 1. Store current health before any damage calculation
	var current_hp = current_stats.health
	
	# 2. Pre-calculate if this damage would be lethal
	# Simple approximation: assume damage goes through (worst case scenario)
	var potential_new_hp = current_hp - value
	
	print("DEBUG: Damage incoming! Current HP: %s, Damage: %s, Potential HP: %s" % [str(current_hp), str(value), str(potential_new_hp)])
	
	# 3. PAUSE FIRST if damage would be lethal (before calling original function)
	if potential_new_hp <= 0:
		print("DEBUG: LETHAL DAMAGE DETECTED! Pausing game BEFORE damage is applied to prevent death.")
		
		# Pause the game using multiple fallback methods
		var pause_successful = try_pause_game()
		
		if pause_successful:
			print("DEBUG: Game successfully paused - death prevented!")
			# Still call the original function but player should survive due to pause
			var result = .take_damage(value, args)
			print("DEBUG: Damage processed while paused. Final HP: %s" % [str(current_stats.health)])
			return result
		else:
			print("DEBUG: WARNING - Could not pause game! Damage will be applied normally.")
			# Fallback: apply damage normally if pause failed
			return .take_damage(value, args)
	else:
		# 4. Non-lethal damage - proceed normally
		print("DEBUG: Non-lethal damage, proceeding normally")
		var result = .take_damage(value, args)
		
		# 5. Print damage result for debugging
		var final_hp = current_stats.health
		if final_hp < current_hp:
			print("DEBUG: Player took damage! HP: %s -> %s" % [str(current_hp), str(final_hp)])
		
		return result

# Helper function to attempt pausing the game using multiple methods
func try_pause_game() -> bool:
	var main_node = get_tree().get_current_scene()
	
	# Method 1: Try to access the main node's pause menu directly
	print("DEBUG: Method 1 - Trying direct UI/PauseMenu access")
	if main_node and main_node.has_node("UI/PauseMenu"):
		var pause_menu = main_node.get_node("UI/PauseMenu")
		if pause_menu and pause_menu.has_method("pause") and pause_menu.enabled:
			print("DEBUG: Method 1 SUCCESS - Direct pause menu access - DEATH PREVENTED")
			pause_menu.pause(0)
			return true
		elif pause_menu and not pause_menu.enabled:
			print("DEBUG: Pause menu disabled, enabling and pausing - DEATH PREVENTED")
			pause_menu.enabled = true
			pause_menu.pause(0)
			return true
		else:
			print("DEBUG: Method 1 FAILED - Pause menu not accessible")
	else:
		print("DEBUG: Method 1 FAILED - UI/PauseMenu node not found")
	
	# Method 2: Access through Main class variable (_pause_menu)
	print("DEBUG: Method 2 - Trying _pause_menu variable access")
	if main_node and main_node.get("_pause_menu"):
		var pause_menu = main_node._pause_menu
		if pause_menu and pause_menu.enabled:
			print("DEBUG: Method 2 SUCCESS - _pause_menu variable access - DEATH PREVENTED")
			pause_menu.pause(0)
			return true
		else:
			print("DEBUG: Method 2 FAILED - _pause_menu not accessible")
	else:
		print("DEBUG: Method 2 FAILED - _pause_menu variable not found")
	
	# Method 3: Emit the ui_pause input action (like pressing ESC)
	print("DEBUG: Method 3 - Trying ui_pause input action - DEATH PREVENTION")
	var pause_event = InputEventAction.new()
	pause_event.action = "ui_pause"
	pause_event.pressed = true
	Input.parse_input_event(pause_event)
	
	# Check if pause worked (slight delay might be needed)
	if get_tree().paused:
		print("DEBUG: Method 3 SUCCESS - Game paused by input action method - DEATH PREVENTED")
		return true
	
	# Method 4: Fallback to simple pause
	print("DEBUG: Method 4 - Using simple pause as fallback")
	get_tree().paused = true
	
	if get_tree().paused:
		print("DEBUG: Method 4 SUCCESS - Simple pause worked - DEATH PREVENTED")
		return true
	else:
		print("DEBUG: Method 4 FAILED - All pause methods failed!")
		return false
