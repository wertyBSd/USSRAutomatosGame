extends Node
## Registry of arcade machines and the transitions between hub and game.

const MACHINES: Array[Dictionary] = [
	{"id": &"naval_battle", "scene": "res://machines/naval_battle/naval_battle.tscn", "title_key": "MACHINE_NAVAL"},
	{"id": &"highway", "scene": "res://machines/highway/highway.tscn", "title_key": "MACHINE_HIGHWAY"},
	{"id": &"tankodrome", "scene": "res://machines/tankodrome/tankodrome.tscn", "title_key": "MACHINE_TANK"},
	{"id": &"sniper", "scene": "res://machines/sniper/sniper.tscn", "title_key": "MACHINE_SNIPER"},
	{"id": &"gorodki", "scene": "res://machines/gorodki/gorodki.tscn", "title_key": "MACHINE_GORODKI"},
]

const HUB_SCENE := "res://hub/hub.tscn"

signal machine_launched(machine_id: StringName)
signal machine_exited(machine_id: StringName, score: int)

var current_machine: StringName = &""


func get_machine_list() -> Array[Dictionary]:
	return MACHINES


func get_machine(id: StringName) -> Dictionary:
	for m in MACHINES:
		if m["id"] == id:
			return m
	return {}


func launch_machine(id: StringName) -> void:
	var data := get_machine(id)
	if data.is_empty():
		push_error("Unknown machine: %s" % id)
		return
	current_machine = id
	machine_launched.emit(id)
	get_tree().change_scene_to_file(data["scene"])


func exit_machine(score: int) -> void:
	if current_machine != &"":
		ScoreStore.record(current_machine, score)
		machine_exited.emit(current_machine, score)
	current_machine = &""
	get_tree().change_scene_to_file(HUB_SCENE)


func go_to_hub() -> void:
	current_machine = &""
	get_tree().change_scene_to_file(HUB_SCENE)
