class_name NotaryRunPanel
extends LootCachePanel
## S04 façade for the run inventory dock. Gameplay provides the one-item source
## and owns the world representation after the emitted placement/drop signals.


func configure(p_inventory: RetrieverInventory, p_source: LootCache) -> void:
	configure_s04(p_inventory, p_source)
