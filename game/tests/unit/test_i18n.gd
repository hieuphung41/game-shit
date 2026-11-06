extends RefCounted


func test_i18n_loads_vietnamese_briefing_title(t) -> bool:
	var previous_locale := TranslationServer.get_locale()
	TranslationServer.set_locale("vi")
	t.eq(tr("BRIEFING_HEADER_TITLE"), "GIỮ GIẤY PHÉP", "Vietnamese briefing title")
	TranslationServer.set_locale(previous_locale)
	return true


func test_i18n_loads_vietnamese_sling_remedy_name(t) -> bool:
	var previous_locale := TranslationServer.get_locale()
	TranslationServer.set_locale("vi")
	t.eq(tr("ITEM_SLING_REMEDY_NAME"), "Gói Băng Muối", "Vietnamese sling remedy name")
	TranslationServer.set_locale(previous_locale)
	return true
