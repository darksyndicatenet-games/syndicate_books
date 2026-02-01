extends Area3D


func interact(_player):
	print("Door opens!")
	open_door()
	queue_free()
	
func open_door():
	pass
