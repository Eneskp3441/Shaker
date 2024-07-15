extends EditorInspectorPlugin

const GRAPH_SCRIPT = preload("res://addons/shaker/src/shaker_graph.gd")
const SHAKER_PANEL = preload("res://addons/shaker/src/shaker_panel.gd")

func _can_handle(object: Object) -> bool:
	return (object is ShakerTypeBase || object is ShakerPresetBase || object is ShakerComponent3D || object is ShakerComponent2D )

func _parse_group(object: Object, group: String) -> void:
	if object is ShakerTypeBase:
		if group == "Live Shake Graph":
			add_graph(object)

func _parse_category(object: Object, category: String) -> void:
	pass

func _parse_begin(object: Object) -> void:
	if object is ShakerComponent3D || object is ShakerComponent2D:
		var _panel:MarginContainer = SHAKER_PANEL.new()
		_panel.Target = object;
		_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
		add_custom_control(_panel)

func _parse_end(object: Object) -> void:
	pass

func add_graph(_object:Object) -> Panel:
	var property_control:Panel = Panel.new()
	property_control.set_script(GRAPH_SCRIPT)
	property_control.shake = _object;
	add_custom_control(property_control)
	property_control.custom_minimum_size.y = 128;
	property_control.set_anchors_preset(Control.PRESET_FULL_RECT)
	return property_control;

func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
	if object is ShakerTypeBase:
		if name == "_temp_graph":
			return true;
	if object is ShakerPresetBase:
		if name == "bake_internal":
			object.Graph = add_graph(object)
	if object is ShakerComponent3D:
		if name == "is_playing":
			#var _panel:Panel = SHAKER_PANEL.new()
			#_panel.Target = object;
			#_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
			#add_custom_control(_panel)
			return true;
	return false;
