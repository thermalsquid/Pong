extends Area2D

export(int) var speed = 500
var direction = Vector2(0, 0)
var prediction_point
onready var base_point = position
var target

onready var screen_size = get_viewport_rect().size
onready var shape = $CollisionShape2D.shape.extents
onready var ball = get_node("../Ball")

# AI uses the linear formula to project where the ball will be, and moves into position to intercept it.
# Right now it's flawless, but it will be made easier with certain amounts of error in the calculation.
# This method is much better than other AI methods I've seen that let the AI cheat.

func _physics_process(delta):
	direction = Vector2(0, 0)
	prediction_point = Vector2(position.x, predict(position.x, ball.direction, ball.position))
	
	# AI should have the same interactions as the player
	if name == "Left":
		if ball.direction.x < 0:
			target = prediction_point
		else:
			target = base_point
	if name == "Right":
		if ball.direction.x > 0:
			target = prediction_point
		else:
			target = base_point
	
	if position.y < target.y - shape.y:
		direction.y = 1
	if position.y > target.y + shape.y:
		direction.y = -1
	
	direction = direction.normalized()
	translate(speed * direction * delta)
	
	if global_position.y < 0 + 32 + shape.y:
		global_position.y = 0 + 32 + shape.y
	if global_position.y > screen_size.y - 32 - shape.y:
		global_position.y = screen_size.y - 32 - shape.y
	
func predict(x, dir, pos):
	# TODO: Replace magic number 8 with proper ball radius
	var top = 0+32+8
	var bottom = screen_size.y-32-8
	var y = intercept_x_at(x, dir, pos)
	
	# Account for ball bounces
	while y < top or y > bottom:
		if y < top:
			y = top + (top - y)
		elif y > bottom:
			y = top + (bottom - top) - (y - bottom)
	
	return y

func intercept_x_at(x, dir, pos):
	# Find the y coordinate the target will be at x coordinate x using the linear formula y - y1 = m(x - x1)
	return (dir.y / dir.x) * (x - pos.x) + pos.y

func _on_AIPaddle_area_entered(area):
	if area.name == "BallArea":
		$AnimationPlayer.play("AnimHit")

func _ready():
	set_physics_process(true)
