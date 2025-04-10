extends Node2D

@onready var MainSceneObject = $ColorRect;

@onready var camera = $Camera2D

var zoneSize = 35;
var click_count = 0;
var isDragging = false;

func _ready():
	get_node("HookNode").SetHook(test);
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, true)
	get_viewport().set_input_as_handled() 
	var screen_size = get_viewport_rect().size
	camera.position = Vector2(screen_size.x / 2, screen_size.y / 2);
	#MainSceneObject.position = camera.project_position(Vector2(screen_size.x / 2,screen_size.y / 2), 10)
	
func _process(_delta):
	#var ZonePosition = camera.unproject_position(MainSceneObject.position)
	var res = get_corners(MainSceneObject);
	DisplayServer.window_set_mouse_passthrough(res)
	if(isDragging):
		MainSceneObject.position = get_global_mouse_position();
		var mouse_pos = DisplayServer.window_get_position() + Vector2i(get_viewport().get_mouse_position())
		DisplayServer.window_set_position(mouse_pos)
	
func ChangeAppActionZone(Base_position):
	var vectors = PackedVector2Array([
	Vector2(Base_position.x - zoneSize, Base_position.y - zoneSize),
	Vector2(Base_position.x - zoneSize, Base_position.y + zoneSize),
	Vector2(Base_position.x + zoneSize, Base_position.y + zoneSize),
	Vector2(Base_position.x + zoneSize, Base_position.y - zoneSize)
	])
	DisplayServer.window_set_mouse_passthrough(vectors)
	
func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		isDragging = true;
	if event is InputEventMouseButton and event.is_released():
		isDragging = false;
		
func _exit_tree():
	get_node("HookNode").Unhook();


func test():
	click_count += 1;
	MainSceneObject.get_node("Label").text = str(click_count);
	MainSceneObject.get_node("AnimatedSprite2D").play("Hit")
	
func get_corners(object) -> Array:
	var top_left = object.global_position 
	var top_right = object.global_position + Vector2(object.size.x, 0)
	var bottom_left = object.global_position + Vector2(0, object.size.y)
	var bottom_right = object.global_position + Vector2(object.size.x, object.size.y)
	return [top_left, top_right, bottom_right, bottom_left]
