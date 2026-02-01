extends RigidBody3D


var is_held := false

func interact(player):
	if player.current_cup != null:
		return

	is_held = true
	freeze = true
	gravity_scale = 0

	player.current_cup = self

	get_parent().remove_child(self)
	player.Hand.add_child(self)

	transform = Transform3D.IDENTITY

	print("Picked up book")
