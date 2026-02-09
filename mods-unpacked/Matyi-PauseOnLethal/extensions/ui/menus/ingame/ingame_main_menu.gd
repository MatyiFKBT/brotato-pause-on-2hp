extends "res://ui/menus/ingame/ingame_main_menu.gd"

var _restart_round_button = null
var _player_node = null

# Signal for restart round button
signal restart_round_button_pressed

func _ready():
	print("DEBUG: [MATYI MOD] IngameMainMenu extension _ready() called!")
	._ready()
	print("DEBUG: [MATYI MOD] Parent _ready() completed, setting up restart button...")
	_setup_restart_round_button()

func _setup_restart_round_button():
	print("DEBUG: Setting up restart round button...")
	
	# Create the restart round button (use regular Button with MyMenuButton script)
	_restart_round_button = Button.new()
	_restart_round_button.text = "RESTART ROUND"
	_restart_round_button.name = "RestartRoundButton"
	_restart_round_button.visible = true  # ALWAYS VISIBLE FOR TESTING
	
	# Try to set script - this might fail, so let's catch it
	var script_resource = load("res://ui/menus/global/my_menu_button.gd")
	if script_resource:
		_restart_round_button.set_script(script_resource)
		print("DEBUG: Script attached successfully")
	else:
		print("DEBUG: Could not load MyMenuButton script")
	
	# Set button styling to match other menu buttons  
	var theme_resource = load("res://resources/themes/base_theme.tres")
	if theme_resource:
		_restart_round_button.theme = theme_resource
		print("DEBUG: Theme applied successfully")
	else:
		print("DEBUG: Could not load theme")
	
	# Find the VBoxContainer that holds the buttons
	print("DEBUG: Looking for buttons container...")
	var buttons_container = get_node_or_null("MarginContainer/HBoxContainer/VBoxContainer2/Buttons")
	if buttons_container:
		print("DEBUG: Found buttons container with %s children" % buttons_container.get_child_count())
		
		# List existing buttons for debugging
		for i in range(buttons_container.get_child_count()):
			var child = buttons_container.get_child(i)
			print("DEBUG: Existing button %s: %s" % [i, child.name])
		
		# Add the button after Resume but before Restart (full run)
		var restart_button_index = -1
		for i in range(buttons_container.get_child_count()):
			var child = buttons_container.get_child(i)
			if child.name == "RestartButton":
				restart_button_index = i
				break
		
		if restart_button_index != -1:
			buttons_container.add_child(_restart_round_button)
			buttons_container.move_child(_restart_round_button, restart_button_index)
			print("DEBUG: Restart round button added to menu at index %s" % restart_button_index)
		else:
			# Fallback: add as second button (after Resume)
			buttons_container.add_child(_restart_round_button)
			buttons_container.move_child(_restart_round_button, 1)
			print("DEBUG: Restart round button added as fallback position")
		
		print("DEBUG: Button added. Container now has %s children" % buttons_container.get_child_count())
		
		# Connect the button signal
		var _error = _restart_round_button.connect("pressed", self, "_on_restart_round_button_pressed")
		if _error == OK:
			print("DEBUG: Button signal connected successfully")
		else:
			print("DEBUG: ERROR connecting button signal: %s" % _error)
		
		# Setup focus navigation
		_setup_focus_navigation()
		
	else:
		print("DEBUG: ERROR - Could not find buttons container")
		# Let's try to list what nodes we can find
		print("DEBUG: Available nodes:")
		_debug_print_children(self, 0)

func _setup_focus_navigation():
	# Update focus neighbors for proper gamepad navigation
	if _restart_round_button:
		var resume_button = get_node_or_null("MarginContainer/HBoxContainer/VBoxContainer2/Buttons/ResumeButton")
		var restart_button = get_node_or_null("MarginContainer/HBoxContainer/VBoxContainer2/Buttons/RestartButton")
		
		if resume_button and restart_button:
			# Set up focus chain: Resume -> Restart Round -> Restart (full run)
			resume_button.focus_neighbour_bottom = _restart_round_button.get_path()
			_restart_round_button.focus_neighbour_top = resume_button.get_path()
			_restart_round_button.focus_neighbour_bottom = restart_button.get_path()
			restart_button.focus_neighbour_top = _restart_round_button.get_path()
			
			print("DEBUG: Focus navigation setup complete")

func _on_restart_round_button_pressed():
	print("DEBUG: Restart round button pressed")
	emit_signal("restart_round_button_pressed")

# Check for lethal pause state when menu is shown
func show():
	.show()
	# Wait one frame for everything to be ready, then check lethal pause state
	call_deferred("_check_lethal_pause_state")

func _check_lethal_pause_state():
	# Try to find and check the player node
	_player_node = _find_player_node()
	if _player_node:
		if _player_node.has_method("is_lethal_pause_active") and _player_node.is_lethal_pause_active():
			print("DEBUG: Lethal pause is active - showing restart round button")
			if _restart_round_button:
				_restart_round_button.visible = true
				_setup_focus_navigation()
		else:
			print("DEBUG: Lethal pause not active - hiding restart round button")
			if _restart_round_button:
				_restart_round_button.visible = false
	else:
		print("DEBUG: Could not find player node")

func _find_player_node():
	# Look for player node in the scene tree using multiple strategies
	var main_scene = get_tree().get_current_scene()
	
	# Strategy 1: Look for get_player() method
	if main_scene and main_scene.has_method("get_player"):
		var player = main_scene.get_player()
		if player and player.has_method("is_lethal_pause_active"):
			return player
	
	# Strategy 2: Search by common paths
	var potential_paths = [
		"Player",
		"Main/Player", 
		"Game/Player",
		"World/Player"
	]
	
	for path in potential_paths:
		if main_scene and main_scene.has_node(path):
			var node = main_scene.get_node(path)
			if node and node.has_method("is_lethal_pause_active"):
				return node
	
	# Strategy 3: Search by group (common pattern in Godot)
	var players = get_tree().get_nodes_in_group("players")
	if players.size() > 0:
		var player = players[0]
		if player.has_method("is_lethal_pause_active"):
			return player
	
	return null

# Debug helper function
func _debug_print_children(node: Node, depth: int):
	var indent = ""
	for i in range(depth):
		indent += "  "
	print("DEBUG: %s%s (%s)" % [indent, node.name, node.get_class()])
	for child in node.get_children():
		if depth < 3:  # Limit depth to avoid spam
			_debug_print_children(child, depth + 1)
