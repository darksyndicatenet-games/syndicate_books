extends Area3D

func interact(player):
	print("Key picked up!")
	Global.is_key_held = true
	queue_free()
