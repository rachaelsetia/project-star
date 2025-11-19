class_name RelicPronghorn extends Enemy

@export var approach_speed: float = 2.0
@export var charge_speed: float = 15.0
@export var charge_duration: float = 1.0
@export var cooldown_duration: float = 2.0

var is_charging: bool = false
var charge_timer: float = 0.0
var cooldown_timer: float = 0.0
var charge_direction: Vector3 = Vector3.ZERO

func _init():
	super()
	vision_radius = 20.0
	attack_radius = 8.0

func _ready():
	super()
	_movement_speed = approach_speed

func _process(delta: float) -> void:	
	super(delta)
	
	if is_charging:
		charge_timer -= delta
		if charge_timer <= 0:
			# ends the charging attack
			is_charging = false
			print("COOLDOWN ACTIVATED")
			cooldown_timer = cooldown_duration
			velocity = Vector3.ZERO
	else:
		var distance_to_player = position.distance_to($"../Player".position)
		if distance_to_player <= attack_radius:
			attack()
		elif distance_to_player <= vision_radius:
			approach()
		else:
			_idle()
	
	if cooldown_timer > 0:
		cooldown_timer -= delta

func _idle() -> void:
	_movement_speed = 0

func approach() -> void:
	set_movement_target($"../Player".position)

func attack() -> void:
	if cooldown_timer > 0:
		return
	
	if is_charging:
		return
	
	print("CHARGE ACTIVATED")
	is_charging = true
	charge_timer = charge_duration
	charge_direction = position.direction_to($"../Player".position).normalized()
	charge_direction.y = 0 # to keep the charging horizontal
	
	if charge_direction.length() > 0.001: # check that vector is nonzero, so it doesn't try to look at itself
		look_at(position + charge_direction, Vector3.UP)

func _physics_process(_delta: float) -> void:
	if is_charging:
		print("CHARGING, Direction: ", charge_direction, ", Velocity: ", velocity)
		velocity = charge_direction * charge_speed
		move_and_slide()
	elif cooldown_timer > 0:
		print("COOLDOWN, Velocity: ", velocity)
		velocity = Vector3.ZERO
		move_and_slide()
	else:
		super(_delta)

func _on_velocity_computed(safe_velocity: Vector3):
	super(safe_velocity)
