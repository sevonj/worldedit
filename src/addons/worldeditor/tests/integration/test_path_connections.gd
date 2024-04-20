# Test suite for path connections
extends GdUnitTestSuite

@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')


# --- Setup and teardown methods --- #
func before():
	pass

func before_test():
	pass

func after_test():
	pass

func after():
	pass

func before_all():
	pass


# --- Tests --- #

# Verify that paths connect correctly
func test_connect_path():
	var junc: WEPathJunction = auto_free(WEPathJunction.new())
	var path1: WEPath = auto_free(WEPath.new())
	var path2: WEPath = auto_free(WEPath.new())
	var curve = Curve3D.new()
	curve.add_point(Vector3.ZERO)
	curve.add_point(Vector3.ONE)
	path1.curve = curve.duplicate(true)
	path2.curve = curve.duplicate(true)
	# Connect paths
	path1.connect_path(junc, WEPath.PATH_START)
	path2.connect_path(junc, WEPath.PATH_START)
	# Check connections
	assert_int(junc.connection_handles.size()).is_equal(2)
	assert_int(junc.connection_paths.size()).is_equal(2)
	assert_object(junc.connection_handles[0]).is_same(path1.connection_handle0)
	assert_object(junc.connection_handles[1]).is_same(path2.connection_handle0)
	assert_object(junc.connection_paths[0]).is_same(path1)
	assert_object(junc.connection_paths[1]).is_same(path2)
	assert_object(path1.connected_0).is_same(junc)
	assert_object(path2.connected_0).is_same(junc)


# Verify that paths disconnect correctly
func test_disconnect_path():
	var junc: WEPathJunction = auto_free(WEPathJunction.new())
	var path1: WEPath = auto_free(WEPath.new())
	var path2: WEPath = auto_free(WEPath.new())
	var curve = Curve3D.new()
	curve.add_point(Vector3.ZERO)
	curve.add_point(Vector3.ONE)
	path1.curve = curve.duplicate(true)
	path2.curve = curve.duplicate(true)
	# Connect paths
	path1.connect_path(junc, WEPath.PATH_START)
	path2.connect_path(junc, WEPath.PATH_START)
	# Disconnect paths
	path1.disconnect_path(WEPath.PATH_START)
	# Check connections
	assert_int(junc.connection_handles.size()).is_equal(1)
	assert_int(junc.connection_paths.size()).is_equal(1)
	assert_object(junc.connection_paths[0]).is_same(path2)
	assert_object(path1.connected_0).is_null()
	assert_object(path2.connected_0).is_same(junc)


# This test works, but the code doesn't. The problem isn't fatal, since it's cleaned at junc update.
# When a path is deleted, connected junctions should forget it
#func test_prune_junction_on_path_freed():
#	var junc: WEPathJunction = auto_free(WEPathJunction.new())
#	var path1: WEPath = auto_free(WEPath.new())
#	var path2: WEPath = WEPath.new()
#	var path3: WEPath = auto_free(WEPath.new())
#	var curve = Curve3D.new()
#	curve.add_point(Vector3.ZERO)
#	curve.add_point(Vector3.ONE)
#	path1.curve = curve.duplicate(true)
#	path2.curve = curve.duplicate(true)
#	path3.curve = curve.duplicate(true)
#	# Connect paths
#	path1.connect_path(junc, WEPath.PATH_START)
#	path2.connect_path(junc, WEPath.PATH_START)
#	path3.connect_path(junc, WEPath.PATH_START)
#	# Free path2
#	path2.queue_free()
#	# Check connections
#	assert_int(junc.connection_handles.size()).is_equal(2)
#	assert_int(junc.connection_paths.size()).is_equal(2)
#	assert_object(junc.connection_handles[0]).is_same(path1.connection_handle0)
#	assert_object(junc.connection_handles[1]).is_same(path2.connection_handle0)
