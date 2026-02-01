extends StaticBody3D
func interact(player):
	# Prevent picking up multiple objects
	if player.current_cup != null:
		return

	pick_up_object(player)

func pick_up_object(player):
	player.current_cup = self

	# Remove from world
	var parent = get_parent()
	if parent:
		parent.remove_child(self)

	# Attach to player's hand
	player.Hand.add_child(self)

	# Reset transform so it snaps to hand
	transform = Transform3D.IDENTITY

	print("Picked up book")
