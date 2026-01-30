extends Node

const MOD_DIR = "Matyi-PauseOn2hp/"

func _init(modLoader = ModLoader):
	modLoader.install_script_extension("res://mods-unpacked/" + MOD_DIR + "extensions/entities/units/player/player.gd")
	print("[matyi] initialized!")
