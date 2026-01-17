extends CharacterBody3D

var speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.8
const SENSITIVITY = 0.004

#bob variables
const BOB_FREQ = 2.4
const BOB_AMP = 0.08
var t_bob = 0.0

#fov variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8

@onready var head = $Head
@onready var camera = $Head/Camera3D

#cup vars
var current_cup =  null
@onready var interaction_ray: RayCast3D =$Head/Camera3D/InteractionRay
@onready var Hand: Marker3D = $Head/Camera3D/Hand
@onready var drop_ray: RayCast3D = $Head/Camera3D/DropRay
@onready var hover_label: Label3D = $Head/Camera3D/HoverLabel


#camera switchingw with computer
var active_computer_cam: Camera3D = null
var using_computer := false
@onready var camera_3d: Camera3D = $Head/Camera3D

#props
var has_key = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))


func _physics_process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

	var obj = interaction_ray.get_collider()
	if Input.is_action_just_pressed("drop"): # map this to a key in InputMap
		drop_cup()
	if Input.is_action_just_pressed("interact"):
		#var obj = interaction_ray.get_collider()
		print("Ray hit: ", obj)
		if obj and obj.has_method("interact"):
			print("Calling interact...")
			obj.interact(self)
			#this is some hellla code shizz top tier
	# --- Hover label code ---
	if obj:
		# Show label above object
		hover_label.visible = true

		# Set text
		if obj.has_meta("display_name"):
			hover_label.text = str(obj.get_meta("display_name"))
		else:
			hover_label.text = obj.name  # fallback to node name

		# Position the label slightly above object
		var aabb = obj.get_aabb() if obj.has_method("get_aabb") else null
		var label_pos = obj.global_transform.origin
		if aabb:
			label_pos.y += aabb.size.y + 0.3  # above object
		else:
			label_pos.y += 1.0
		hover_label.global_transform.origin = label_pos

	else:
		hover_label.visible = false


	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Handle Sprint.
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
	
	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	move_and_slide()


func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

func drop_cup():
	if current_cup == null:
		return # No cup to drop

	if not drop_ray.is_colliding():
		print("Nothing under to drop on!")
		return

	var drop_pos = drop_ray.get_collision_point()

	# Remove cup from hand
	current_cup.get_parent().remove_child(current_cup)
	get_parent().add_child(current_cup) # put in world root
	current_cup.global_transform.origin = drop_pos

	print("Dropped cup at: ", drop_pos)

	current_cup = null
	
