// Adapted from Boid.cs implementation provided on Canvas with player collision added

using Godot;
using System;
using System.Collections.Generic;

public partial class XpBoid : Area2D
{
	[Signal] public delegate void CollectedEventHandler();

	[Export] public float MaxSpeed = 300f;
	[Export] public float SeparationWeight = 15f;
	[Export] public float AlignmentWeight = 10f;
	[Export] public float CohesionWeight = 10f;
	[Export] public float FollowWeight = 2000f;
	[Export] public float FollowRadius = 30f;

	private List<XpBoid> _neighbors = new();
	private Area2D _detectionArea;
	private Area2D _targetArea;
	private Vector2 _velocity = Vector2.Zero;

	public override void _Ready()
	{
		// Initialize boid velocity
		var angle = GD.Randf() * Mathf.Pi * 2;
		_velocity = new Vector2(Mathf.Cos(angle), Mathf.Sin(angle)) * MaxSpeed * 2;

		// Set up detection area for neighbors
		_detectionArea = GetNode<Area2D>("DetectionArea");
		_detectionArea.BodyEntered += OnBodyEntered;
		_detectionArea.BodyExited += OnBodyExited;

		// Connect root Area2D to detect player
		AreaEntered += OnAreaEntered;
	}

	public void SetTarget(Area2D target)
	{
		_targetArea = target;
	}

	public override void _Process(double delta)
	{
		Vector2 separation = Separation() * SeparationWeight;
		Vector2 alignment = Alignment() * AlignmentWeight;
		Vector2 cohesion = Cohesion() * CohesionWeight;
		Vector2 follow = Centralization() * FollowWeight;

		_velocity += (separation + alignment + cohesion + follow) * (float)delta;
		_velocity = _velocity.LimitLength(MaxSpeed);

		Position += _velocity * (float)delta;
		LookAt(Position + _velocity);
	}

	// Player collision
	private void OnAreaEntered(Area2D area)
	{
		if (area.Name == "Player")
		{
			EmitSignal("Collected");
			QueueFree();
		}
	}

	// Flocking neighbor detection
	private void OnBodyEntered(Node body)
	{
		if (body is XpBoid boid && boid != this)
			_neighbors.Add(boid);
	}

	private void OnBodyExited(Node body)
	{
		if (body is XpBoid boid && boid != this)
			_neighbors.Remove(boid);
	}

	private Vector2 Separation()
	{
		if (_neighbors.Count == 0) return Vector2.Zero;

		Vector2 steer = Vector2.Zero;
		foreach (var neighbor in _neighbors)
		{
			Vector2 diff = Position - neighbor.Position;
			steer += diff.Normalized() / diff.Length();
		}
		return steer.Normalized();
	}

	private Vector2 Alignment()
	{
		if (_neighbors.Count == 0) return Vector2.Zero;

		Vector2 avgVelocity = Vector2.Zero;
		foreach (var neighbor in _neighbors)
			avgVelocity += neighbor._velocity;

		avgVelocity /= _neighbors.Count;
		return avgVelocity.Normalized();
	}

	private Vector2 Cohesion()
	{
		if (_neighbors.Count == 0) return Vector2.Zero;

		Vector2 center = Vector2.Zero;
		foreach (var neighbor in _neighbors)
			center += neighbor.Position;

		center /= _neighbors.Count;
		return (center - Position).Normalized();
	}

	private Vector2 Centralization()
	{
		if (_targetArea != null)
		{
			Vector2 targetPos = _targetArea.GlobalPosition;
			if (Position.DistanceTo(targetPos) < FollowRadius)
				return Vector2.Zero;
			return (targetPos - Position).Normalized();
		}
		return Vector2.Zero;
	}
}
