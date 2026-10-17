extends Node
## Thin wrapper over TranslationServer so call sites stay short.

func t(key: StringName, args: Array = []) -> String:
	var s := tr(key)
	if not args.is_empty():
		s = s % args
	return s


func has_locale(code: String) -> bool:
	return Settings.LOCALES.has(code)


func get_locales() -> PackedStringArray:
	return Settings.LOCALES
