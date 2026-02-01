extends Area3D
@onready var object_placed: Marker3D = $ObjectPlaced

var body_inside: RigidBody3D = null

func _physics_process(_delta: float) -> void:
	if body_inside and Input.is_action_just_pressed("place"):
		move_to_marker(body_inside, object_placed)
		print("placed")
	
	
func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("books"):
		body_inside = body

func move_to_marker(body: Node3D, marker: Marker3D):
	body.freeze = true
	body.linear_velocity = Vector3.ZERO
	body.angular_velocity = Vector3.ZERO
	body.global_transform = marker.global_transform


func _on_body_exited(body: Node3D) -> void:
	if body == body_inside:
		body_inside = null
