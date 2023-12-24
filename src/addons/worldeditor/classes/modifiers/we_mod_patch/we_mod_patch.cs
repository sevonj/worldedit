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
			Godot.Collections.Array samples = (Godot.Collections.Array)parent.Call("get_samples");
			GenerateMesh(samples, parent);
		}
		catch (Exception e)
		{
			GD.PushError("Update failed.", e);
		}

	}

	public void GenerateMesh(Godot.Collections.Array samples, Node3D parent)
	{
		Material mat_default = (Material)ResourceLoader.Load("res://addons/worldeditor/assets/materials/mat_tool_patch.tres");
		ArrayMesh mesh;
		SurfaceTool st = new();
		st.Begin(Mesh.PrimitiveType.Triangles);

		IPoint[] points = Delanaute(Samples2Points(samples));
		foreach (IPoint point in points.Reverse())
		{
			Vector3 vec = new((float)point.X, 0, (float)point.Y);
			st.AddVertex(vec);
		}

		//st.GenerateNormals();
		mesh = st.Commit();
		mesh.SurfaceSetMaterial(0, mat_default);
		meshinstance.Mesh = mesh;
	}

	public IPoint[] Delanaute(IPoint[] points)
	{
		Delaunator d = new(points);
		ITriangle[] triangles = d.GetTriangles().ToArray();

		// Triangles to vec
		IPoint[] returnpoints = new IPoint[triangles.Count() * 3];
		for (int i = 0; i < triangles.Count(); i++)
		{
			IPoint[] tri_points = triangles[i].Points.ToArray();
			returnpoints[i * 3] = tri_points[0];
			returnpoints[i * 3 + 1] = tri_points[1];
			returnpoints[i * 3 + 2] = tri_points[2];
		}
		return returnpoints;
	}

	private static IPoint[] Samples2Points(Godot.Collections.Array samples)
	{
		IPoint[] points = new IPoint[samples.Count];
		for (int i = 0; i < samples.Count; i++)
		{
			Transform3D sample = (Transform3D)samples[i];
			points[i] = new Point
			{
				X = sample.Origin.X,
				Y = sample.Origin.Z
			};
		}
		return points;
	}

	public (Vector3 min, Vector3 max) GetAABB(Godot.Collections.Array samples)
	{
		Transform3D _sample = (Transform3D)samples[0];
		Vector3 min = _sample.Origin;
		Vector3 max = _sample.Origin;
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
