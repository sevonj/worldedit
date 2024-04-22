## This is an empty class.
## Instances are used as an identifiers for each end connections of a WEPath
class_name WEConnectionHandle extends Resource

var _owner: WEPath
var _end: int

# --- Virtual Methods --- #


func _init(owner: WEPath, end: int):
	_owner = owner
	_end = end


# --- Public --- #


## Which path does this handle belong to?
func get_owner() -> WEPath:
	return _owner


## Which end of the path is this
func get_end() -> int:
	return _end
