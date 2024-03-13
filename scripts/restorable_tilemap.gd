extends TileMap
class_name RestorableTileMap

var original_tiles_ids := PoolIntArray()
var original_tiles_positions := PoolVector2Array()

func _ready():
	original_tiles_positions = get_used_cells()
	for index in original_tiles_positions.size():
		original_tiles_ids.append(get_cellv(original_tiles_positions[index]))


func restore_original_tiles():
	for index in original_tiles_positions.size():
		set_cellv(original_tiles_positions[index], original_tiles_ids[index])



