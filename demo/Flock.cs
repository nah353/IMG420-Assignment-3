// Original Flock.cs implementation adapted from Canvas

using Godot;
using System;

public partial class Flock : Node2D
{
	[Export] public PackedScene BoidScene;
	
	public XpBoid SpawnBoidAtPosition(Vector2 pos, Area2D player)
	{
		if (BoidScene == null)
		{
			GD.PrintErr("BoidScene not set.");
			return null;
		}
		
		XpBoid boid = BoidScene.Instantiate<XpBoid>();
		boid.Position = pos;
		boid.SetTarget(player);
		
		AddChild(boid);
		return boid;
	}
}
