using Godot;
using System;
using System.Numerics;

[GlobalClass, Tool]
public partial class we_mod_road : Node
{
	MeshInstance3D meshinstance = new();

	[Export]
	float width = 8;

	public override void _Ready()
	{
		AddChild(meshinstance);
		meshinstance.SetMeta("_edit_lock_", true);
		try
		{
			Path3D parent = (Path3D)GetParent();
			parent.Connect("updated", Callable.From(() => Refresh()));
		}
		catch (Exception e)
		{
			GD.PushError("Failed to connect parent.", e);
		}
	}

	public void Refresh()
	{
		Path3D path;

		try
		{
			path = (Path3D)GetParent();
			Godot.Collections.Array samples = (Godot.Collections.Array)path.Get("samples");
			GenerateMesh(samples);
		}
		catch (Exception e)
		{
			GD.PushError("Refresh failed.", e);
		}

	}

	public void GenerateMesh(Godot.Collections.Array samples)
	{

		Material mat_default = (Material)ResourceLoader.Load("res://addons/worldeditor/assets/materials/mat_tool_gray_02.tres");
		ArrayMesh mesh;
		SurfaceTool st = new();
		st.Begin(Mesh.PrimitiveType.Triangles);

		for (int seg_idx = 0; seg_idx < samples.Count - 1; seg_idx++)
		{
			Transform3D curr = (Transform3D)samples[seg_idx];
			Transform3D next = (Transform3D)samples[seg_idx + 1];

			Godot.Vector3 v0 = curr * (Godot.Vector3.Left * width / 2);
			Godot.Vector3 v1 = next * (Godot.Vector3.Left * width / 2);
			Godot.Vector3 v2 = curr.Origin;
			Godot.Vector3 v3 = next.Origin;
			Godot.Vector3 v4 = curr * (Godot.Vector3.Right * width / 2);
			Godot.Vector3 v5 = next * (Godot.Vector3.Right * width / 2);

			Godot.Vector2 uv0 = new(-1, 0);
			Godot.Vector2 uv1 = new(-1, -1);
			Godot.Vector2 uv2 = new(0, 0);
			Godot.Vector2 uv3 = new(0, -1);
			Godot.Vector2 uv4 = new(1, 0);
			Godot.Vector2 uv5 = new(1, -1);

			st.SetUV(uv0);
			st.AddVertex(v0);
			st.SetUV(uv1);
			st.AddVertex(v1);
			st.SetUV(uv2);
			st.AddVertex(v2);
			st.SetUV(uv3);
			st.AddVertex(v3);
			st.SetUV(uv4);
			st.AddVertex(v4);
			st.SetUV(uv5);
			st.AddVertex(v5);
		}

		for (int seg_idx = 0; seg_idx < samples.Count - 1; seg_idx++)
		{
			int seg_off = seg_idx * 6;
			st.AddIndex(seg_off + 0);
			st.AddIndex(seg_off + 1);
			st.AddIndex(seg_off + 2);

			st.AddIndex(seg_off + 2);
			st.AddIndex(seg_off + 1);
			st.AddIndex(seg_off + 3);


			st.AddIndex(seg_off + 2);
			st.AddIndex(seg_off + 3);
			st.AddIndex(seg_off + 4);

			st.AddIndex(seg_off + 4);
			st.AddIndex(seg_off + 3);
			st.AddIndex(seg_off + 5);
		}

		st.GenerateNormals();
		mesh = st.Commit();
		mesh.SurfaceSetMaterial(0, mat_default);
		meshinstance.Mesh = mesh;
	}

}
