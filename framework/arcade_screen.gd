class_name ArcadeScreen
extends Node
## Wraps every mini-game in a fixed 320x240 SubViewport and renders it through
## a CRT shader, so machines only ever deal with one small screen size.

const VIEW_SIZE := Vector2i(320, 240)

@export var game_scene: PackedScene
@export var machine_id: StringName = &""

var game: GameBase = null

@onready var _viewport: SubViewport = %SubViewport
@onready var _screen: TextureRect = %Screen
@onready var _material: ShaderMaterial = _screen.material


func _ready() -> void:
	_viewport.size = VIEW_SIZE
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_viewport.disable_3d = true
	_screen.texture = _viewport.get_texture()
	_apply_crt_setting()
	Settings.changed.connect(_apply_crt_setting)
	_spawn_game()
	game.game_over.connect(_on_game_over)


func _apply_crt_setting() -> void:
	_material.set_shader_parameter("enabled", Settings.crt_enabled)


func _spawn_game() -> void:
	if game_scene == null:
		push_error("ArcadeScreen: game_scene is not set")
		return
	game = game_scene.instantiate() as GameBase
	if game == null:
		push_error("ArcadeScreen: scene root is not a GameBase")
		return
	game.machine_id = machine_id
	_viewport.add_child(game)
	game.start()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		game.quit_to_hub()


func _on_game_over(final_score: int) -> void:
	GameManager.exit_machine(final_score)
