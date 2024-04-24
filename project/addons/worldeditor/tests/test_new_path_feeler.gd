# Test suite for path connections
extends GdUnitTestSuite

@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")

var feeler: NewPathFeeler

# --- Setup and teardown methods --- #
func before():
	pass


func before_test():
	feeler = NewPathFeeler.new()
	add_child(feeler)


func after_test():
	pass


func after():
	pass


func before_all():
	pass


# --- Tests --- #

func test_commit_creates_path():
	var path := feeler._commit()
	assert_object(path).is_instanceof(WEPath)


func test_commit_creates_path_with_correct_position():
	feeler.global_position = Vector3.ONE
	var path := feeler._commit()
	assert_object(path).is_instanceof(WEPath)
	assert_vector(path.global_position).is_equal(Vector3.ONE)


func test_commit_with_junction_connects():
	var junc = auto_free(WEPathJunction.new())
	feeler._junction = junc
	var path := feeler._commit()
	assert_object(path).is_instanceof(WEPath)
	assert_object(path.connected_0).is_same(junc)


func test_commit_with_junction_with_correct_points():
	var junc := auto_free(WEPathJunction.new())
	junc.global_position = -Vector3.ONE
	feeler.global_position = Vector3.ONE
	feeler._junction = junc
	var path := feeler._commit()
	assert_int(path.curve.point_count).is_equal(2)
	assert_vector(path.curve.get_point_position(0)).is_equal(-Vector3.ONE)
	assert_vector(path.curve.get_point_position(1)).is_equal(Vector3.ONE)
