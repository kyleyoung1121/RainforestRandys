extends CharacterBody3D


var speed
const SPRINT_SPEED = 5.5
const WALK_SPEED = 3.5
const JUMP_VELOCITY = 3.0
const SENSITIVITY = 0.0012

# Bob Variables
const BOB_FREQUENCY = 3.0
const BOB_AMPLITUDE = 0.02
var bob_progress = 0.0

# FOV Variables
const BASE_FOV = 80.0
const FOV_CHANGE = 1.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Track the player's shopping list items
var shopping_list = [
	"beer",  
	"apple_juice",
	"spaghetti", 
	"tortilla",
	"spaghetti",
	#"apple_pie",
	"instant_noodles",
	"schlamey",
	"hot_sauce",
	"tomato_soup",
	"cups",
	"ham",
	"mak_and_cheese",
	"canned_beans",
	"instant_coffee",
	"milk",
	"toy_robot",
	"red_wine",
	"white_wine",
	"bacon",
	"chicken_breast",
	"hamburger_patties",
	"hot_dogs",
	"soda",
	#"pizza_dough",
	"brownies"
]
var items_collected = 0

# Get component references
@onready var head = $Head
@onready var camera = $Head/Camera3D


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event):
	# Check if the mouse has moved
	if event is InputEventMouseMotion:
		# Move the camera accordingly
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		# Set a min & max looking angle
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))


func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Handle sprint
	# TODO: add stamina
	# TODO: allow toggle sprint, so they dont have to hold it the whole time
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Allow the player to move the character if they are on the ground
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = 0
			velocity.z = 0
		
	# If the player is mid-air, allow partial control
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 4)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 4)
	
	# Handle head bob
	bob_progress += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(bob_progress)
	
	# Change FOV slightly based on player speed
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 5.0)
	
	move_and_slide()


func _headbob(time) -> Vector3:
	var head_position = Vector3.ZERO
	# Calculate bob up and down
	head_position.y = sin(time * BOB_FREQUENCY) * BOB_AMPLITUDE
	# Calculate bob left to right
	head_position.x = cos(time * BOB_FREQUENCY / 2) * BOB_AMPLITUDE
	return head_position
