using Godot;
using System;
using DelaunatorSharp;
using System.Linq;

[GlobalClass, Tool]
public partial class we_mod_patch : Node
{
	MeshInstance3D meshinstance = new();

	public override void _Ready()
	{
		AddChild(meshinstance);
		meshinstance.SetMeta("_edit_lock_", true);

		try
		{
			Node3D parent = (Node3D)GetParent();
			parent.Connect("updated", Callable.From(() => Update()));
		}
		catch (Exception e)
		{
			GD.PushError("Failed to connect parent.", e);
		}
	}

	public void Update()
	{
		Node3D parent;

		try
		{
			parent = (Node3D)GetParent();
			Vector3[] path_points = ((Godot.Collections.Array<Vector3>)parent.Call("get_path_points")).ToArray();
			Transform3D[] samples = ((Godot.Collections.Array<Transform3D>)parent.Call("get_samples")).ToArray();

			GenerateMesh(samples, path_points);
		}
		catch (Exception e)
		{
			GD.PushError("Update failed.", e);
		}

	}


	public void GenerateMesh(Transform3D[] samples, Vector3[] path_points)
	{
		Material mat_default = (Material)ResourceLoader.Load("res://addons/worldeditor/assets/materials/mat_tool_patch.tres");
		ArrayMesh mesh;
		SurfaceTool st = new();
		st.Begin(Mesh.PrimitiveType.Triangles);


		IPoint[] points = Delaunate(Samples2Points(samples));

		foreach (IPoint point in points.Reverse())
		{
			float x = (float)point.X;
			float z = (float)point.Y;
			float y = GetVertexHeight(new(x, z), samples);

			st.SetUV(new(x, z));
			st.AddVertex(new(x, y, z));
		}

		st.GenerateNormals();
		mesh = st.Commit();
		mesh.SurfaceSetMaterial(0, mat_default);
		meshinstance.Mesh = mesh;
	}

	public static IPoint[] Delaunate(IPoint[] points)
	{
		Delaunator d = new(points);
		ITriangle[] triangles = d.GetTriangles().ToArray();

		// Triangles to vec
		IPoint[] returnpoints = new IPoint[triangles.Length * 3];
		for (int i = 0; i < triangles.Length; i++)
		{
			IPoint[] tri_points = triangles[i].Points.ToArray();
			returnpoints[i * 3] = tri_points[0];
			returnpoints[i * 3 + 1] = tri_points[1];
			returnpoints[i * 3 + 2] = tri_points[2];
		}
		return returnpoints;
	}

	private static IPoint[] Samples2Points(Transform3D[] samples)
	{
		IPoint[] points = new IPoint[samples.Length];
		for (int i = 0; i < samples.Length; i++)
		{
			points[i] = new Point
			{
				X = samples[i].Origin.X,
				Y = samples[i].Origin.Z
			};
		}
		return points;
	}

	public static float GetVertexHeight(Vector2 position, Transform3D[] samples)
	{
		// Only considers edge vertices, because for now the patch only has edge vertices.
		foreach (Transform3D sample in samples)
		{
			Vector3 vert = sample.Origin;
			Vector2 flatVert = new(vert.X, vert.Z);
			float distance = flatVert.DistanceTo(position);

			if (distance <= 0.01)
				return vert.Y;
		}
		return 0;
	}

	public static (Vector3 min, Vector3 max) GetAABB(Transform3D[] samples)
	{
		Vector3 min = samples[0].Origin;
		Vector3 max = samples[0].Origin;
		foreach (Transform3D sample in samples)
		{
			min.X = Math.Min(min.X, sample.Origin.X);
			min.Y = Math.Min(min.Y, sample.Origin.Y);
			min.Z = Math.Min(min.Z, sample.Origin.Z);
			max.X = Math.Max(max.X, sample.Origin.X);
			max.Y = Math.Max(max.Y, sample.Origin.Y);
			max.Z = Math.Max(max.Z, sample.Origin.Z);
		}
		return (min, max);
	}
}
