extends Node

const MOD_DIR = "Matyi-PauseOnLethal/"

func _init(modLoader = ModLoader):
	# Install player extension
	modLoader.install_script_extension("res://mods-unpacked/" + MOD_DIR + "extensions/entities/units/player/player.gd")
	
	# Install menu extensions for restart round button
	modLoader.install_script_extension("res://mods-unpacked/" + MOD_DIR + "extensions/ui/menus/ingame/ingame_main_menu.gd")
	modLoader.install_script_extension("res://mods-unpacked/" + MOD_DIR + "extensions/ui/menus/ingame/ingame_menus.gd")
	
	print("[matyi] PauseOnLethal initialized with restart round feature!")
