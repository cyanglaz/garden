extends GutTest

func test_item_stores_callable() -> void:
	var ran := [false]
	var cm := CombatMain.new()
	autofree(cm)
	var c := func(p_cm: CombatMain) -> void:
		ran[0] = true
		assert_eq(p_cm, cm)
	var item = CombatQueueItem.new()
	item.callback = c
	item.callback.call(cm)
	assert_true(ran[0])


func test_item_stores_unique_id() -> void:
	var item = CombatQueueItem.new()
	item.unique_id = "dedupe_id"
	assert_eq(item.unique_id, "dedupe_id")


func test_item_default_category_is_empty() -> void:
	var item = CombatQueueItem.new()
	assert_eq(item.category, "")


func test_item_stores_category() -> void:
	var item = CombatQueueItem.new()
	item.category = "weather"
	assert_eq(item.category, "weather")


func test_request_default_category_is_empty() -> void:
	var request = CombatQueueRequest.new()
	assert_eq(request.category, "")


func test_request_stores_category() -> void:
	var request = CombatQueueRequest.new()
	request.category = "weather"
	assert_eq(request.category, "weather")
