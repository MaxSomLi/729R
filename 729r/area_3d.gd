extends Area3D


@onready var part = get_parent()
@onready var cube = part.get_parent()
@onready var parts = cube.get_children()
const DIFF = 0.01



func _ready() -> void:
	connect("input_event", Callable(self, "_on_input_event"))

func _on_input_event(_camera, event, _click_position, _click_normal, _shape_idx) -> void:
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and cube.rotating.size() == 0:
		var x = event.relative.x
		var y = event.relative.y
		if abs(x) > abs(y):
			cube.is_x = false
			var same = part.global_position.y
			for p in parts:
				if abs(p.global_position.y - same) < DIFF:
					cube.rotating.append(p)
		elif abs(y) > abs(x):
			cube.is_x = true
			var same = part.global_position.x
			for p in parts:
				if abs(p.global_position.x - same) < DIFF:
					cube.rotating.append(p)
