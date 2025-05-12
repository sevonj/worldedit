# WorldEdit

[➜ See also: WorldEdit II](https://github.com/sevonj/worldedit2)

An unfinished spline-based terrain generator for Godot game engine.

Runs in editor, <sub>mistakenly</sub> written entirely in GDScript.

![demo](https://github.com/user-attachments/assets/8ba23650-1efc-4699-84d3-1cddf3ff9485)

![roads](https://github.com/user-attachments/assets/f5823f1a-5e21-4cc6-a2cd-c34c28d6ade9)



| ![test_shaded](https://github.com/user-attachments/assets/aee14662-3373-43e3-9656-c342d354e36a) | ![test_wireframe](https://github.com/user-attachments/assets/6f4251dd-1b8e-422b-9f6e-c9ba5d810c3c) |
|-------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------|
| Roads & terrain shaded                                                                          | Roads & terrain wireframe                                                                          |

| ![structure](https://github.com/user-attachments/assets/b12e0443-530e-402d-bfae-29e01efa83e1) | ![modifiers](https://github.com/user-attachments/assets/c4a7c4fd-0c60-4780-8590-6487e7ca6a33)                                         |
|-----------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------|
| The world is a network of splines and junctions.                                              | The network itself doesn't do anything. Actual mesh generation is handled by modifier nodes. Pic: Road mesh components under splines. |

Inspired by Volition's amazing tool:
- 2011 GDC talk: https://gdcvault.com/play/1014717/Building-Open-Worlds-Faster-the
- 2018 GDC talk: https://gdcvault.com/play/1025244/Spline-Based-Procedural-Modeling-in
