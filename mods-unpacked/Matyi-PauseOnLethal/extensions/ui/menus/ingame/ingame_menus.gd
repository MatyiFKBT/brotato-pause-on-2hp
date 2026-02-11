extends "res://ui/menus/ingame/ingame_menus.gd"

func _ready():
	._ready()
	_connect_restart_round_signal()

func _connect_restart_round_signal():
	# Connect to the restart round button signal from the main menu
	if _main_menu and _main_menu.has_signal("restart_round_button_pressed"):
		if not _main_menu.is_connected("restart_round_button_pressed", self, "_on_restart_round_button_pressed"):
			_main_menu.connect("restart_round_button_pressed", self, "_on_restart_round_button_pressed")
			print("DEBUG: Connected restart round button signal")
	else:
		print("DEBUG: Main menu or restart round signal not found")

func _on_restart_round_button_pressed():
	print("DEBUG: Restart round button signal received")
	
	# Find the player node and call restart function
	var player_node = _find_player_node()
	if player_node and player_node.has_method("restart_current_round"):
		print("DEBUG: Calling restart_current_round on player")
		player_node.restart_current_round()
	else:
		print("DEBUG: ERROR - Player node not found or restart method missing")
		# Fallback: direct restart logic
		_fallback_restart_round()

func _find_player_node():
	# Look for player node in the scene tree
	var main_scene = get_tree().get_current_scene()
	if main_scene and main_scene.has_method("get_player"):
		return main_scene.get_player()
	
	# Alternative: search for player node by path patterns
	var potential_paths = [
		"Player",
		"Main/Player", 
		"Game/Player",
		"World/Player"
	]
	
	for path in potential_paths:
		if main_scene and main_scene.has_node(path):
			var node = main_scene.get_node(path)
			if node and node.has_method("restart_current_round"):
				return node
	
	return null

func _fallback_restart_round():
	print("DEBUG: Using fallback restart round logic")
	
	# Clear pause state
	get_tree().paused = false
	
	# Use existing retry wave functionality
	RunData.reset_to_start_wave_state()
	RunData.retries += 1
	
	# Restart the scene
	var _error = get_tree().change_scene(MenuData.game_scene)
	print("DEBUG: Fallback restart completed")