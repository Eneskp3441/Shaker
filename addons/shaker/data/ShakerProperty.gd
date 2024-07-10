@tool
@icon("res://addons/shaker/assets/ShakerPreset.svg")
class_name ShakerProperty
extends Resource

@export var property_name:String
# Properties
@export var shake_type:ShakerTypeBase

# Signal for property changes
signal property_changed(name: StringName)

func _init(property_name:String="", shake_type:ShakerTypeBase=null) -> void:
	self.property_name = property_name
	self.shake_type = shake_type

# Handle property changes
func _on_property_changed(property_name: StringName) -> void:
	property_changed.emit(property_name)

func get_value(_t:float) -> Variant:
	if shake_type:
		return shake_type.get_value(_t)
	return 0.0
