class_name GameBase
extends Node2D
## Base class for every arcade machine. Subclasses override the virtual methods
## and emit request_exit to return to the hub.

signal score_changed(score: int)
signal game_over(final_score: int)
signal request_exit(final_score: int)

@export var machine_id: StringName = &""

var score: int = 0
var running: bool = false


func _ready() -> void:
	set_process(false)
	set_physics_process(false)


## Called by the machine screen once the viewport is sized.
func start() -> void:
	score = 0
	running = true
	set_process(true)
	set_physics_process(true)
	score_changed.emit(score)
	_on_start()


func add_score(amount: int) -> void:
	if not running:
		return
	score = maxi(0, score + amount)
	score_changed.emit(score)


func end_game() -> void:
	if not running:
		return
	running = false
	set_process(false)
	set_physics_process(false)
	game_over.emit(score)


func quit_to_hub() -> void:
	running = false
	set_process(false)
	set_physics_process(false)
	request_exit.emit(score)


# --- Virtual hooks -------------------------------------------------------

func _on_start() -> void:
	pass


func _on_update(_delta: float) -> void:
	pass


func _on_physics_update(_delta: float) -> void:
	pass


func _process(delta: float) -> void:
	if running:
		_on_update(delta)


func _physics_process(delta: float) -> void:
	if running:
		_on_physics_update(delta)
