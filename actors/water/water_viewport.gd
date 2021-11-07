tool
extends Sprite

onready var viewport: Viewport = $Viewport
onready var water: Polygon2D = $Viewport/WaterPolygon
onready var detection_area: Area2D = $DetectionArea
onready var collision: CollisionPolygon2D = $DetectionArea/Collision

export var polygon: PoolVector2Array = PoolVector2Array()
export var water_texture: Texture = load("res://actors/water/water_texture.png")
export var water_texture_size: Vector2 = Vector2(64, 64)
export var water_color: Color = Color(0, 0.7, 1, 0.8)
export var outline_color: Color = Color(0.2, 0.7, 1, 0.8)
export var outline_size: float = 6;
export var texture_color_impact: float = 0.2;
export var animation_swing_range: float = 32;
export var animation_speed: float = 1;

func refresh():
	viewport.world_2d = get_world_2d()
	#get the extends
	var min_vec = Vector2.INF
	var max_vec = -Vector2.INF
	for poly in polygon:
		min_vec.x = min(min_vec.x, poly.x)
		min_vec.y = min(min_vec.y, poly.y)
		max_vec.x = max(max_vec.x, poly.x)
		max_vec.y = max(max_vec.y, poly.y)
	if min_vec == Vector2.INF: #if we have 0 polygons, then don't do anything
		return
	#set the size to the extends of the polygon
	var size_extends = max_vec - min_vec
	var size_diff = Vector2(0, size_extends.y * 1.5)
	viewport.size = size_extends + size_diff
	#set the water polygon and start it
	water.position += size_diff / 2
	water.polygon = polygon
	#now set the collision polygon
	collision.polygon = PoolVector2Array([
		Vector2(0, 0), Vector2(size_extends.x, 0),
		size_extends, Vector2(0, size_extends.y)
	])
	#handle position stuff
	position += size_extends / 2
	collision.position -= size_extends / 2
	detection_area.top_left_corner = position - size_extends / 2
	#start!
	detection_area.on_ready()
	
	#shader copy time
	var tex = ImageTexture.new()
	tex.create(viewport.size.x, viewport.size.y, Image.FORMAT_RGB8)
	texture = tex
	#now give the shader our viewport texture
	material.set_shader_param("viewport_texture", viewport.get_texture())
	material.set_shader_param("outline_color", outline_color)
	material.set_shader_param("outline_size", outline_size)
	
	#set the water shaders
	var mat = water.material
	mat.set_shader_param("water_texture", water_texture)
	mat.set_shader_param("base_water_color", water_color)
	mat.set_shader_param("water_texture_size", water_texture.get_size())
	mat.set_shader_param("texture_repeat", (size_extends / water_texture_size).y)
	mat.set_shader_param("water_xy_ratio", Vector2(size_extends.x / size_extends.y, 1))
	mat.set_shader_param("normal_map_mult", texture_color_impact)
	mat.set_shader_param("animation_swing_range_px", animation_swing_range)
	mat.set_shader_param("animation_speed", animation_speed)

func _draw():
	if Engine.editor_hint:
		var colors = PoolColorArray()
		for poly in polygon:
			colors.append(Color(0, 0.7, 1))#water_color)
		draw_polygon(polygon, colors)
		for poly in polygon:
			draw_circle(poly, 3, Color(0, 1, 1))

func _ready():
	if !Engine.editor_hint:
		refresh()