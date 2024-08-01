package pong

import rl "vendor:raylib"

Vec2 :: [2]f32

Arena :: struct {
	rect: rl.Rectangle,
}

Paddle :: struct {
	rect:  rl.Rectangle,
	speed: f32,
}

Ball :: struct {
	circle:   Circle,
	velocity: Vec2,
	speed:    f32,
}

Circle :: struct {
	center: Vec2,
	radius: f32,
}

PongState :: struct {
	score:   [2]int,
	arena:   Arena,
	paddles: [2]Paddle,
	ball:    Ball,
}

state: PongState

init :: proc() {
	score := [2]int{0, 0}
	arena := create_arena()
	paddles := create_paddles(arena)
	ball := create_ball(arena)

	state = PongState{score, arena, paddles, ball}
}

update :: proc() {
	update_paddles()
	update_ball()
}

draw :: proc() {
	draw_arena()
	draw_paddles(state.paddles)
	draw_ball(state.ball)
}

@(private)
update_paddles :: proc() {
	paddle_left := &state.paddles[0]
	paddle_right := &state.paddles[1]

	if rl.IsKeyDown(.W) do paddle_left.rect.y -= paddle_left.speed
	if rl.IsKeyDown(.S) do paddle_left.rect.y += paddle_left.speed

	if rl.IsKeyDown(.UP) do paddle_right.rect.y -= paddle_right.speed
	if rl.IsKeyDown(.DOWN) do paddle_right.rect.y += paddle_right.speed
}

@(private)
update_ball :: proc() {
	state.ball.circle.center.x += state.ball.velocity.x * state.ball.speed
	state.ball.circle.center.y += state.ball.velocity.y * state.ball.speed

	if determine_paddle_collision() do state.ball.velocity.x *= -1
	if determine_arena_collision() do state.ball.velocity.y *= -1
}

@(private)
determine_paddle_collision :: proc() -> bool {
	ball_speed := state.ball.speed
	ball_velocity := state.ball.velocity
	ball_radius := state.ball.circle.radius
	ball_x := &state.ball.circle.center.x
	ball_y := &state.ball.circle.center.y

	ball_x^ += ball_velocity.x * ball_speed
	ball_y^ += ball_velocity.y * ball_speed

	ball_right_edge := ball_x^ + ball_radius
	ball_left_edge := ball_x^ - ball_radius

	ball_top_edge := ball_y^ + ball_radius
	ball_bottom_edge := ball_y^ - ball_radius

	for &paddle, i in state.paddles {
		paddle_left_edge := paddle.rect.x
		paddle_right_edge := paddle.rect.x + paddle.rect.width
		paddle_top_edge := paddle.rect.y
		paddle_bottom_edge := paddle.rect.y + paddle.rect.height

		if ball_right_edge > paddle_left_edge &&
		   ball_left_edge < paddle_right_edge {
			if paddle_top_edge <= ball_bottom_edge &&
			   paddle_bottom_edge >= ball_top_edge {
				return true
			}
		}
	}

	return false
}

@(private)
determine_arena_collision :: proc() -> bool {
	ball_top := state.ball.circle.center.y - state.ball.circle.radius
	ball_bottom := state.ball.circle.center.y + state.ball.circle.radius

	arena_top := state.arena.rect.y
	arena_bottom := state.arena.rect.y + state.arena.rect.height

	return ball_top <= arena_top || ball_bottom >= arena_bottom
}

@(private)
draw_arena :: proc() {
	rl.DrawRectangleRec(state.arena.rect, rl.DARKGRAY)
}

@(private)
draw_paddles :: proc(paddles: [2]Paddle) {
	rl.DrawRectangleRec(paddles[0].rect, rl.BLUE)
	rl.DrawRectangleRec(paddles[1].rect, rl.BLUE)
}

@(private)
draw_ball :: proc(ball: Ball) {
	rl.DrawCircleV(ball.circle.center, ball.circle.radius, rl.RAYWHITE)
}

@(private)
create_arena :: proc() -> Arena {
	screen_width := f32(rl.GetScreenWidth())
	screen_height := f32(rl.GetScreenHeight())

	rect_width := screen_width * 0.5
	rect_height := screen_height * 0.5
	rect_x := (screen_width - rect_width) * 0.5
	rect_y := (screen_height - rect_height) * 0.5

	return Arena{rect = {rect_x, rect_y, rect_width, rect_height}}
}

@(private)
create_paddles :: proc(arena: Arena) -> [2]Paddle {
	paddle_width: f32 = 10
	paddle_height: f32 = 100
	paddle_offset: f32 = 20
	paddle_speed: f32 = 2

	paddle_left := Paddle {
		rect = {
			x = arena.rect.x + paddle_offset,
			y = arena.rect.y + (arena.rect.height - paddle_height) * 0.5,
			width = paddle_width,
			height = paddle_height,
		},
		speed = paddle_speed,
	}

	paddle_right := Paddle {
		rect = {
			x = arena.rect.x + arena.rect.width - paddle_offset - paddle_width,
			y = arena.rect.y + (arena.rect.height - paddle_height) * 0.5,
			width = paddle_width,
			height = paddle_height,
		},
		speed = paddle_speed,
	}

	return [2]Paddle{paddle_left, paddle_right}
}

@(private)
create_ball :: proc(arena: Arena) -> Ball {
	circle_radius: f32 = 7

	circle := Circle {
		center = Vec2 {
			arena.rect.x + arena.rect.width * 0.5,
			arena.rect.y + arena.rect.height * 0.5,
		},
		radius = circle_radius,
	}

	return Ball{circle = circle, velocity = Vec2{1, 0.2}, speed = 1}
}
