extends Node3D

const SENS = 0.005
const SNAP = [0.5*PI, PI, 1.5*PI, -0.5*PI, -PI, -1.5*PI]
@onready var face = $/root/Main/Face
var is_x = false
var rotating := []
const CHILDREN = 26
const RADIUS = 0.1
@onready var parts = get_children()
const VISIBLE_Z_BORDER = 0.9
const Z = 1.5
const POS = [-1, 0, 1]
const DIFF = 0.01
const FIRST = POS[0]
const CENTER = POS[1]
const LAST = POS[2]
const STEP = 1



func _ready() -> void:
	add_new_sphere()

func _input(event) -> void:
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		rotate(Vector3.RIGHT, event.relative.y*SENS)
		rotate(Vector3.UP, event.relative.x*SENS)
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and rotating.size() > 0:
		for cr in rotating:
			cr.reparent(face)
		if is_x:
			face.rotate(Vector3.RIGHT, event.relative.y*SENS)
		else:
			face.rotate(Vector3.UP, event.relative.x*SENS)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		rotation = Vector3(closest(rotation.x), closest(rotation.y), closest(rotation.z))
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed and get_child_count() < CHILDREN:
		face.rotation = Vector3(closest(face.rotation.x), closest(face.rotation.y), closest(face.rotation.z))
		var lc = face.get_children()
		for c in lc:
			c.reparent(self)
		rotating = []
	elif event is InputEventKey and event.pressed:
		if Input.is_action_pressed("ui_up"):
			move_up()
		elif Input.is_action_pressed("ui_down"):
			move_down()
		elif Input.is_action_pressed("ui_left"):
			move_left()
		elif Input.is_action_pressed("ui_right"):
			move_right()

func closest(v: float) -> float:
	var min_dist = abs(v)
	var new = 0
	for s in SNAP:
		var h = abs(v - s)
		if h < min_dist:
			min_dist = h
			new = s
	return new

func visible_face() -> Array:
	var arr = []
	for p in parts:
		if p.global_position.z > VISIBLE_Z_BORDER:
			arr.append(p)
	return arr

func has_space(p: MeshInstance3D) -> bool:
	var ch = p.get_children()
	for c in ch:
		if c is MeshInstance3D and c.global_position.z > VISIBLE_Z_BORDER:
			return false
	return true

func add_new_sphere() -> void:
	var arr = visible_face()
	var empty = []
	for p in arr:
		if has_space(p):
			empty.append(p)
	var s = empty.size()
	if s > 0:
		var holder = empty[randi_range(0, s - 1)]
		var new_sphere = MeshInstance3D.new()
		new_sphere.mesh = SphereMesh.new()
		new_sphere.mesh.radius = RADIUS
		new_sphere.mesh.height = 2*RADIUS
		new_sphere.mesh.material = load("res://mat1.tres")
		holder.add_child(new_sphere)
		new_sphere.global_position = Vector3(holder.global_position.x, holder.global_position.y, Z)

func move_left() -> void:
	for y in POS:
		var x = CENTER
		while x <= LAST:
			var s = find_sphere_by_pos(Vector3(x, y, Z))
			if s != null:
				var t = x - STEP
				while t >= FIRST:
					if find_sphere_by_pos(Vector3(t, y, Z)) == null:
						s.reparent(find_part_by_pos(Vector3(t, y, STEP)))
						s.global_position = Vector3(t, y, Z)
					t -= STEP
			x += STEP
		var a = find_sphere_by_pos(Vector3(FIRST, y, Z))
		var b = find_sphere_by_pos(Vector3(CENTER, y, Z))
		var c = find_sphere_by_pos(Vector3(LAST, y, Z))
		if c != null:
			if a.mesh.material == b.mesh.material and a.mesh.material == c.mesh.material:
				c.queue_free()
				b.queue_free()
				change_material(a)
	add_new_sphere()

func move_right() -> void:
	for y in POS:
		var x = CENTER
		while x >= FIRST:
			var s = find_sphere_by_pos(Vector3(x, y, Z))
			if s != null:
				var t = x + STEP
				while t <= LAST:
					if find_sphere_by_pos(Vector3(t, y, Z)) == null:
						s.reparent(find_part_by_pos(Vector3(t, y, STEP)))
						s.global_position = Vector3(t, y, Z)
					t += STEP
			x -= STEP
		var a = find_sphere_by_pos(Vector3(FIRST, y, Z))
		var b = find_sphere_by_pos(Vector3(CENTER, y, Z))
		var c = find_sphere_by_pos(Vector3(LAST, y, Z))
		if a != null:
			if a.mesh.material == b.mesh.material and a.mesh.material == c.mesh.material:
				a.queue_free()
				b.queue_free()
				change_material(c)
	add_new_sphere()

func move_down() -> void:
	for x in POS:
		var y = CENTER
		while y <= LAST:
			var s = find_sphere_by_pos(Vector3(x, y, Z))
			if s != null:
				var t = y - STEP
				while t >= FIRST:
					if find_sphere_by_pos(Vector3(x, t, Z)) == null:
						s.reparent(find_part_by_pos(Vector3(x, t, STEP)))
						s.global_position = Vector3(x, t, Z)
					t -= STEP
			y += STEP
		var a = find_sphere_by_pos(Vector3(x, FIRST, Z))
		var b = find_sphere_by_pos(Vector3(x, CENTER, Z))
		var c = find_sphere_by_pos(Vector3(x, LAST, Z))
		if c != null:
			if a.mesh.material == b.mesh.material and a.mesh.material == c.mesh.material:
				c.queue_free()
				b.queue_free()
				change_material(a)
	add_new_sphere()

func move_up() -> void:
	for x in POS:
		var y = CENTER
		while y >= FIRST:
			var s = find_sphere_by_pos(Vector3(x, y, Z))
			if s != null:
				var t = y + STEP
				while t <= LAST:
					if find_sphere_by_pos(Vector3(x, t, Z)) == null:
						s.reparent(find_part_by_pos(Vector3(x, t, STEP)))
						s.global_position = Vector3(x, t, Z)
					t += STEP
			y -= STEP
		var a = find_sphere_by_pos(Vector3(x, FIRST, Z))
		var b = find_sphere_by_pos(Vector3(x, CENTER, Z))
		var c = find_sphere_by_pos(Vector3(x, LAST, Z))
		if a != null:
			if a.mesh.material == b.mesh.material and a.mesh.material == c.mesh.material:
				a.queue_free()
				b.queue_free()
				change_material(c)
	add_new_sphere()

func find_part_by_pos(pos: Vector3) -> MeshInstance3D:
	for p in parts:
		if (p.global_position - pos).length() < DIFF:
			return p
	return null

func find_sphere_by_pos(pos: Vector3) -> MeshInstance3D:
	for p in parts:
		var ch = p.get_children()
		for c in ch:
			if c is MeshInstance3D and (c.global_position - pos).length() < DIFF:
				return c
	return null

func change_material(p: MeshInstance3D) -> void:
	if p.mesh.material == load("res://mat1.tres"):
		p.mesh.material = load("res://mat2.tres")
	elif p.mesh.material == load("res://mat2.tres"):
		p.mesh.material = load("res://mat3.tres")
	elif p.mesh.material == load("res://mat3.tres"):
		p.mesh.material = load("res://mat4.tres")
	elif p.mesh.material == load("res://mat4.tres"):
		p.mesh.material = load("res://mat5.tres")
	else:
		get_tree().change_scene_to_file("res://res.tscn")
