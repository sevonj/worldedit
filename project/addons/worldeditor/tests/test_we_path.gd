# Test suite for path connections
extends GdUnitTestSuite

@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")

var path: WEPath

# --- Setup and teardown methods --- #
func before():
	pass


func before_test():
	path = WEPath.new()
	add_child(path)


func after_test():
	pass


func after():
	pass


func before_all():
	pass


# --- Tests --- #
# If all curve points are deleted, the path should self-destruct.
func test_free_self_on_empty_curve():
	assert_bool(path.is_queued_for_deletion()).is_false()
	path.curve.clear_points()
	assert_bool(path.is_queued_for_deletion()).is_true()
