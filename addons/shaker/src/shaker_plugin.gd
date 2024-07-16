@tool
extends EditorPlugin

var SHAKER_INSPECTOR_PLUGIN:EditorInspectorPlugin = preload("res://addons/shaker/src/shaker_inspector.gd").new()

func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	add_inspector_plugin(SHAKER_INSPECTOR_PLUGIN)
	add_autoload_singleton("Shaker", "res://addons/shaker/src/Shaker.gd")

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_inspector_plugin(SHAKER_INSPECTOR_PLUGIN)
	remove_autoload_singleton("Shaker")
