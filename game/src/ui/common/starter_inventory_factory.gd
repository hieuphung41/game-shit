class_name StarterInventoryFactory
extends RefCounted
## Temporary S02 fixture. It builds item data through ItemRegistry and delegates
## placement and validation entirely to RetrieverInventory.


static func create() -> RetrieverInventory:
	var registry := ItemRegistry.new()
	var remedy := ItemDef.new()
	remedy.id = &"starter_remedy"
	remedy.display_name_vi = "starter_remedy"
	remedy.size = Vector2i(1, 2)
	remedy.rotatable = true
	remedy.sealable = true
	remedy.item_category = ItemDef.Category.CONSUMABLE
	registry.add(remedy)

	var inventory := RetrieverInventory.new(registry)
	inventory.load_snapshot({
		"backpack": [],
		"notary_box": [{"uid": 1, "def_id": &"starter_remedy", "quantity": 1, "anchor": Vector2i.ZERO, "rotated": false}],
		"sling_pouch": [{"uid": 2, "def_id": &"starter_remedy", "quantity": 1, "anchor": Vector2i.ZERO, "rotated": false}],
	})
	return inventory
