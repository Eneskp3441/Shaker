@tool
extends Panel

const TIME_LINE_SCRIPT: GDScript = preload("res://addons/shaker/src/shaker_timeline.gd")
const ShakerBase3d = preload("res://addons/shaker/src/Vector3/ShakerBase3D.gd")
const ShakerBase2d = preload("res://addons/shaker/src/Vector2/ShakerBase2D.gd")

# Graph properties
var graph_points:Array[PackedFloat32Array]
var y_scale: float = 32.0
var width: float = 2.0
var shake: Resource
var graph_offset: Vector2 = Vector2(15.0, 0.0)

# Private variables
var _graph_min: float = -1.0
var _graph_max: float = 1.0
var _graph_max_total: float = 1.0
var layout_box: HBoxContainer = HBoxContainer.new()
var axis_button: OptionButton = OptionButton.new()
var fit_button: Button = Button.new()
var category_button: OptionButton
var time_line: Control
var flip_y: bool = true
var selected_category: int = 0
var graph_pressing: bool = false
var graph_middle_pressing: bool = false
var point_color_by_axis:Array[Color] = [Color.RED, Color.GREEN, Color.DEEP_SKY_BLUE]
var _unselected_opacity:float = .10

# Graph time offset property
var graph_time_offset: float = 0.0:
	set = set_graph_time_offset,
	get = get_graph_time_offset

# Called when the node enters the scene tree for the first timeX
func _ready() -> void:
	shake.property_changed.connect(on_property_changed)
	
	clip_contents = true
	_setup_timeline()
	_setup_layout_box()
	_setup_fit_button()
	_setup_category_button()
	_setup_axis_button()
	
	_update_graph()
	_on_fit_button_clicked()

# Sets up the timeline
func _setup_timeline() -> void:
	if shake is ShakerPresetBase:
		time_line = TIME_LINE_SCRIPT.new()
		time_line.GRAPH = self
		add_child(time_line)

# Sets up the layout box
func _setup_layout_box() -> void:
	add_child(layout_box)
	layout_box.set_anchors_preset(Control.PRESET_TOP_WIDE)
	layout_box.custom_minimum_size.y = 16
	layout_box.alignment = BoxContainer.ALIGNMENT_END

# Sets up the fit button
func _setup_fit_button() -> void:
	layout_box.add_child(fit_button)
	fit_button.text = "Fit"
	fit_button.pressed.connect(_on_fit_button_clicked)

# Sets up the category button
func _setup_category_button() -> void:
	if shake is ShakerPresetBase:
		category_button = OptionButton.new()
		category_button.item_selected.connect(_on_category_selected)
		layout_box.add_child(category_button)
		category_button.custom_minimum_size = Vector2(16, 16)
		for _category_index in shake.Categories.size():
			var _category_name: StringName = shake.Categories.keys()[_category_index]
			var _category_value: int = shake.Categories.values()[_category_index]
			category_button.add_item(_category_name, _category_value)
		if shake.Categories.size() > 0: category_button.select(0)

# Sets up the axis button
func _setup_axis_button() -> void:
	if axis_button.get_parent() != layout_box:
		layout_box.add_child(axis_button)
		axis_button.position = Vector2(-32, 4)
		axis_button.custom_minimum_size = Vector2(16, 16)
		axis_button.item_selected.connect(_axis_selected)
		axis_button.add_theme_color_override("background_color", Color.GREEN)
	
	var selected:int = max(axis_button.get_selected_id(), 0)
	axis_button.clear()
	var Axis:Array = []
	
	if shake is ShakerTypeBase:
		Axis = shake.GraphAxis.keys()
	elif shake is ShakerPresetBase:
		var shakes:Array = shake.get_shakes_by_category(category_button.selected)
		if shakes.size() > 0 && shakes[0]:
			Axis = shakes[0].get_script().GraphAxis.keys()
	for axis in Axis:
		axis_button.add_item(axis)
	selected = min(selected, Axis.size())
	if Axis.size() > 0:
		axis_button.select(selected)

# Updates the graph
func _update_graph() -> void:
	graph_points.clear()
	if not axis_button.get_selected_id() < 0:
		var _baked: float = round(shake.bake_internal)
		_graph_min = 0.0
		_graph_max = 0.0
		graph_points.resize(axis_button.item_count)
		for axis_index in axis_button.item_count:
			for i in _baked + 1:
				var _args: Array = [graph_time_offset + (i / _baked)]
				if shake is ShakerPresetBase:
					_args.append(selected_category)
				var _val = shake.callv("get_value", _args)
				if typeof(_val) != TYPE_FLOAT: _val = _val[axis_index]
				var _result: float = _val * (-1 if flip_y else 1)
				graph_points[axis_index].append(_result)
				_graph_min = min(_graph_min, _result)
				_graph_max = max(_graph_max, _result)
		_graph_max_total = max(abs(_graph_max), abs(_graph_min))

# Draws the graph
func _draw() -> void:
	_draw_zero_line()
	_draw_min_max()
	_draw_graph_points()
	_draw_graph_info()

# Draws the zero line
func _draw_zero_line() -> void:
	var font_size: int = 8
	draw_line(Vector2(0, size.y * 0.5), Vector2(size.x, size.y * 0.5), Color.DIM_GRAY, 1, false)
	draw_string(ThemeDB.fallback_font, Vector2(5.0, size.y * 0.5 + font_size * 0.5), "0", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.DIM_GRAY, TextServer.JUSTIFICATION_NONE, TextServer.DIRECTION_AUTO, TextServer.ORIENTATION_HORIZONTAL)

# Draws the min/max values
func _draw_min_max() -> void:
	var font_size: int = 8
	var _view_percent: float = (y_scale * _graph_max_total) / (size.y * 0.5)
	if (_view_percent * _graph_max_total) > 0.25:
		var _padding: int = 10
		var _up_offset: float = max((-size.y * 0.5) * min(_view_percent, 1.0), -size.y * 0.5 + _padding)
		var _down_offset: float = min((size.y * 0.5) * min(_view_percent, 1.0), size.y * 0.5 - _padding)
		var _min_max_percent: float = 1.0 / max(_view_percent, 1.0)
		draw_string(ThemeDB.fallback_font, Vector2(5.0, size.y * 0.5 + font_size * 0.5 + _up_offset), "%.2f" % (1.0 * _graph_max_total * _min_max_percent), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.DIM_GRAY, TextServer.JUSTIFICATION_NONE, TextServer.DIRECTION_AUTO, TextServer.ORIENTATION_HORIZONTAL)
		draw_string(ThemeDB.fallback_font, Vector2(5.0, size.y * 0.5 + font_size * 0.5 + _down_offset), "%.2f" % (1.0 * _graph_min * _min_max_percent), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.DIM_GRAY, TextServer.JUSTIFICATION_NONE, TextServer.DIRECTION_AUTO, TextServer.ORIENTATION_HORIZONTAL)

# Draws the graph points
func _draw_graph_points() -> void:
	for axis_index in graph_points.size():
		var _point_length:int = graph_points[axis_index].size()
		var _point_color:Color = point_color_by_axis[fmod(axis_index, point_color_by_axis.size())]
		var alpha:float = _unselected_opacity if axis_index != axis_button.get_selected_id() else 1.0
		var _final_size: Vector2 = size - graph_offset
		var _offset: Vector2 = Vector2(1, y_scale)
		for point_index in _point_length:
			var _size_offset = Vector2((_final_size.x / (_point_length)) * point_index, _final_size.y * 0.5)
			var point:float = graph_points[axis_index][point_index]
			if point_index < _point_length - 1:
				var _size_offset_next = Vector2((_final_size.x / (_point_length)) * (point_index + 1), _final_size.y * 0.5)
				var point_next:float = graph_points[axis_index][point_index + 1]
				var _final_point_1: Vector2 = graph_offset + _size_offset + Vector2(0.0, point) * _offset
				var _final_point_2: Vector2 = graph_offset + _size_offset_next + Vector2(0.0, point_next) * _offset
				draw_line(_final_point_1, _final_point_2, _point_color * Color(1,1,1, alpha), width, false)

# Draws the graph info
func _draw_graph_info() -> void:
	var font_size: int = 8
	var _text = "Zoom: %.2f  |   Zoom IN / OUT with mouse scroll" % (y_scale / (size.y * 0.5 / _graph_max_total))
	var _text_size: float = _text.length() * font_size * 0.5
	draw_string(ThemeDB.fallback_font, Vector2(size.x - _text_size, size.y - 8.0), _text, HORIZONTAL_ALIGNMENT_RIGHT, -1, font_size, Color.GRAY, TextServer.JUSTIFICATION_NONE, TextServer.DIRECTION_AUTO, TextServer.ORIENTATION_HORIZONTAL)

# Handles GUI input
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_handle_mouse_button(event)
	if event is InputEventMouseMotion:
		_handle_mouse_motion(event)

# Handles mouse button input
func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		y_scale -= 1.0 / _graph_max_total
		accept_event()
	elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
		y_scale += 1.0 / _graph_max_total
		accept_event()
	elif event.button_index == MOUSE_BUTTON_LEFT:
		if shake is ShakerPresetBase:
			graph_pressing = event.pressed
			update_timeline_position(event.position)
	if event.button_index == MOUSE_BUTTON_MIDDLE:
		if shake is ShakerPresetBase:
			graph_middle_pressing = event.pressed
	y_scale = max(y_scale, 1)
	queue_redraw()

# Handles mouse motion input
func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	if graph_pressing:
		update_timeline_position(event.position)
	if graph_middle_pressing:
		graph_time_offset += -(event.relative.x / size.x)
		graph_time_offset = max(graph_time_offset, 0.0)

# Updates the timeline position
func update_timeline_position(pos: Vector2) -> void:
	if shake is ShakerPresetBase:
		var _press_percent: float = max(((pos.x) - graph_offset.x) / (size.x - graph_offset.x), 0.0)
		if shake.parent is ShakerBase3d || shake.parent is ShakerBase2d:
			var _shaker_component = shake.parent
			if _shaker_component != null:
				_shaker_component.set_progress(_press_percent + graph_time_offset)

# Called when a property changes
func on_property_changed(_name: StringName) -> void:
	_setup_axis_button()
	_update_graph()
	queue_redraw()
	if is_inf(y_scale) or is_nan(y_scale):
		_on_fit_button_clicked()

# Called when an axis is selected
func _axis_selected(item: int) -> void:
	_update_graph()
	_on_fit_button_clicked()

# Called when the fit button is clicked
func _on_fit_button_clicked() -> void:
	y_scale = (size.y * 0.5) / _graph_max_total
	graph_time_offset = 0.0
	queue_redraw()

# Called when a category is selected
func _on_category_selected(item: int) -> void:
	selected_category = item
	_setup_axis_button()
	_update_graph()
	_on_fit_button_clicked()

# Setter for graph_time_offset
func set_graph_time_offset(value: float) -> void:
	graph_time_offset = value
	if time_line != null:
		time_line.queue_redraw()
	_update_graph()
	queue_redraw()

# Getter for graph_time_offset
func get_graph_time_offset() -> float:
	return graph_time_offset

func select_axis(index:int) -> void:
	if axis_button.has_selectable_items():
		axis_button.select(index)

func select_category(index:int) -> void:
	if category_button.has_selectable_items():
		category_button.select(index)
