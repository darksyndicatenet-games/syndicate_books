extends Node3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_door_open: bool = false
func _physics_process(_delta: float) -> void:
	if Global.is_key_held == true && !is_door_open:
		animation_player.play("both_door")
		#animation_player.play("slider_door2Action")
		print("Door should open")
		is_door_open = true
		#pass
