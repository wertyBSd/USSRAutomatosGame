extends Node
## Persistent user settings: audio, CRT effect, language.

const PATH := "user://settings.cfg"

const LOCALES: PackedStringArray = [
	"ru", "en", "de", "fr", "es", "it",
	"pt", "pl", "tr", "zh_CN", "ja", "ko",
]

signal changed

var master_volume: float = 0.8
var music_volume: float = 0.6
var sfx_volume: float = 0.8
var crt_enabled: bool = true
var language: String = "ru"


func _ready() -> void:
	load_settings()


func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK:
		return
	master_volume = cfg.get_value("audio", "master", master_volume)
	music_volume = cfg.get_value("audio", "music", music_volume)
	sfx_volume = cfg.get_value("audio", "sfx", sfx_volume)
	crt_enabled = cfg.get_value("video", "crt", crt_enabled)
	language = cfg.get_value("general", "language", language)
	_apply_all()


func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "master", master_volume)
	cfg.set_value("audio", "music", music_volume)
	cfg.set_value("audio", "sfx", sfx_volume)
	cfg.set_value("video", "crt", crt_enabled)
	cfg.set_value("general", "language", language)
	cfg.save(PATH)


func set_volume(bus: StringName, value: float) -> void:
	match bus:
		&"Master":
			master_volume = clampf(value, 0.0, 1.0)
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), linear_to_db(master_volume))
		&"Music":
			music_volume = clampf(value, 0.0, 1.0)
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), linear_to_db(music_volume))
		&"SFX":
			sfx_volume = clampf(value, 0.0, 1.0)
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), linear_to_db(sfx_volume))
	save_settings()
	changed.emit()


func set_crt(enabled: bool) -> void:
	crt_enabled = enabled
	save_settings()
	changed.emit()


func set_language(code: String) -> void:
	if not LOCALES.has(code):
		return
	language = code
	TranslationServer.set_locale(code)
	save_settings()
	changed.emit()


func _apply_all() -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(&"Master"), linear_to_db(master_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(&"Music"), linear_to_db(music_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(&"SFX"), linear_to_db(sfx_volume))
	TranslationServer.set_locale(language)
