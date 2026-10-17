extends Node
## Best and last scores per machine, persisted to user://scores.cfg.

const PATH := "user://scores.cfg"

var _best: Dictionary = {}
var _last: Dictionary = {}

signal score_recorded(machine_id: StringName, score: int, is_record: bool)


func _ready() -> void:
	load_scores()


func load_scores() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK:
		return
	for section in cfg.get_sections():
		if section == "best":
			for key in cfg.get_section_keys(section):
				_best[StringName(key)] = int(cfg.get_value(section, key))
		elif section == "last":
			for key in cfg.get_section_keys(section):
				_last[StringName(key)] = int(cfg.get_value(section, key))


func save_scores() -> void:
	var cfg := ConfigFile.new()
	for id in _best:
		cfg.set_value("best", String(id), _best[id])
	for id in _last:
		cfg.set_value("last", String(id), _last[id])
	cfg.save(PATH)


func record(machine_id: StringName, score: int) -> bool:
	_last[machine_id] = score
	var is_record := score > get_best(machine_id)
	if is_record:
		_best[machine_id] = score
	save_scores()
	score_recorded.emit(machine_id, score, is_record)
	return is_record


func get_best(machine_id: StringName) -> int:
	return int(_best.get(machine_id, 0))


func get_last(machine_id: StringName) -> int:
	return int(_last.get(machine_id, 0))
