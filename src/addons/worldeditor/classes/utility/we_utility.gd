class_name WEUtility


static func get_center(vectors: Array[Vector3]) -> Vector3:
	""" Returns the middle of 3d points """
	if vectors.size() == 0:
		push_error("Err: Called with empty vector.")
		return Vector3.ZERO
	return (component_min(vectors) + component_max(vectors)) / 2


static func component_min(vectors: Array[Vector3]) -> Vector3:
	var min = vectors[0]
	for i in vectors.size():
		min.x = min(min.x, vectors[i].x)
		min.y = min(min.y, vectors[i].y)
		min.z = min(min.z, vectors[i].z)
	return min


static func component_max(vectors: Array[Vector3]) -> Vector3:
	var max = vectors[0]
	for i in vectors.size():
		max.x = max(max.x, vectors[i].x)
		max.y = max(max.y, vectors[i].y)
		max.z = max(max.z, vectors[i].z)
	return max
