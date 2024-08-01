package pong

import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:strings"
import rl "vendor:raylib"

@(private)
Vec2 :: [2]f32

@(private)
GameState :: enum {
	StartScreen,
	Countdown,
	Playing,
	GameOver,
}

@(private)
Arena :: struct {
	rect: rl.Rectangle,
}

@(private)
Paddle :: struct {
	rect:  rl.Rectangle,
	speed: f32,
}

@(private)
Ball :: struct {
	circle:   Circle,
	velocity: Vec2,
	speed:    f32,
}

@(private)
Circle :: struct {
	center: Vec2,
	radius: f32,
}

@(private)
PongState :: struct {
	score:      [2]int,
	arena:      Arena,
	paddles:    [2]Paddle,
	ball:       Ball,
	game_state: GameState,
	countdown:  u8,
}

@(private)
state: PongState

@(private)
LAST_UPDATE_TIME := rl.GetTime()

init :: proc() {
	score := [2]int{0, 0}
	arena := create_arena()
	paddles := create_paddles(arena)
	ball := create_ball(arena)

	state = PongState{score, arena, paddles, ball, .StartScreen, 3}
}

/* UPDATE PROCEDURES */

update :: proc() {
	switch state.game_state {
	case .StartScreen:
		update_start_screen()
	case .Countdown:
		update_countdown()
	case .Playing:
		update_game()
	case .GameOver:
		update_game_over()
	}
}

@(private)
update_start_screen :: proc() {
	if rl.IsKeyPressed(.SPACE) {
		state.game_state = .Countdown
		reset_game()
	}
}

@(private)
update_countdown :: proc() {
	current_time := rl.GetTime()

	if state.countdown > 0 {
		if current_time - LAST_UPDATE_TIME >= 1.0 {
			state.countdown -= 1

			LAST_UPDATE_TIME = current_time

			if state.countdown == 0 do state.game_state = .Playing
		}
	}
}


@(private)
update_game :: proc() {
	update_paddles()
	update_ball()
	update_score()
}

@(private)
update_game_over :: proc() {
	if rl.IsKeyPressed(.SPACE) {
		reset_game_state()
		state.game_state = .Countdown
	}
}

@(private)
update_paddles :: proc() {
	paddle_left := &state.paddles[0]
	paddle_right := &state.paddles[1]

	if rl.IsKeyDown(.W) do paddle_left.rect.y -= paddle_left.speed
	if rl.IsKeyDown(.S) do paddle_left.rect.y += paddle_left.speed

	if rl.IsKeyDown(.UP) do paddle_right.rect.y -= paddle_right.speed
	if rl.IsKeyDown(.DOWN) do paddle_right.rect.y += paddle_right.speed

	determine_paddles_arena_collision()
}

@(private)
update_ball :: proc() {
	state.ball.circle.center.x += state.ball.velocity.x * state.ball.speed
	state.ball.circle.center.y += state.ball.velocity.y * state.ball.speed

	determine_paddle_collision()
	determine_arena_collision()
}

@(private)
update_score :: proc() {
	ball_left := state.ball.circle.center.x - state.ball.circle.radius
	ball_right := state.ball.circle.center.x + state.ball.circle.radius

	arena_left := state.arena.rect.x
	arena_right := state.arena.rect.x + state.arena.rect.width

	if ball_left <= arena_left do state.score[1] += 1
	else if ball_right >= arena_right do state.score[0] += 1
	else do return

	if state.score[0] == 3 || state.score[1] == 3 do state.game_state = .GameOver

	reset_ball()
	reset_paddles()
}

/* DRAW PROCEDURES */

draw :: proc() {
	switch state.game_state {
	case .StartScreen:
		draw_start_screen()
	case .Countdown:
		draw_countdown()
	case .Playing:
		draw_game()
	case .GameOver:
		draw_game_over()
	}
}

@(private)
draw_start_screen :: proc() {
	rl.ClearBackground(rl.BLACK)

	title_text: cstring = "PONG"
	font_size: i32 = 60
	text_width := rl.MeasureText(title_text, font_size)

	rl.DrawText(
		title_text,
		i32(rl.GetScreenWidth() / 2 - text_width / 2),
		100,
		font_size,
		rl.WHITE,
	)

	instruction_text: cstring = "Press SPACE to start"
	instruction_font_size: i32 = 30
	instruction_width := rl.MeasureText(
		instruction_text,
		instruction_font_size,
	)

	rl.DrawText(
		instruction_text,
		i32(rl.GetScreenWidth() / 2 - instruction_width / 2),
		300,
		instruction_font_size,
		rl.GRAY,
	)
}

@(private)
draw_countdown :: proc() {
	draw_game()

	countdown_text := rl.TextFormat("%d", state.countdown)
	font_size: i32 = 100
	text_width := rl.MeasureText(countdown_text, font_size)

	rl.DrawText(
		countdown_text,
		i32(rl.GetScreenWidth() / 2 - text_width / 2),
		i32(rl.GetScreenHeight() / 2 - font_size / 2),
		font_size,
		rl.WHITE,
	)
}

@(private)
draw_game :: proc() {
	draw_arena()
	draw_paddles(state.paddles)
	draw_ball(state.ball)
	draw_score(state.score)
}

@(private)
draw_game_over :: proc() {
	draw_game()

	game_over_text: cstring = "GAME OVER"
	font_size: i32 = 60
	text_width := rl.MeasureText(game_over_text, font_size)

	rl.DrawText(
		game_over_text,
		i32(rl.GetScreenWidth() / 2 - text_width / 2),
		100,
		font_size,
		rl.WHITE,
	)

	winner_text := rl.TextFormat(
		"Player %d Wins!",
		state.score[0] > state.score[1] ? 1 : 2,
	)
	winner_font_size: i32 = 40
	winner_text_width := rl.MeasureText(winner_text, winner_font_size)

	rl.DrawText(
		winner_text,
		i32(rl.GetScreenWidth() / 2 - winner_text_width / 2),
		250,
		winner_font_size,
		rl.GOLD,
	)

	restart_text: cstring = "Press SPACE to restart"
	restart_font_size: i32 = 30
	restart_text_width := rl.MeasureText(restart_text, restart_font_size)

	rl.DrawText(
		restart_text,
		i32(rl.GetScreenWidth() / 2 - restart_text_width / 2),
		300,
		restart_font_size,
		rl.GRAY,
	)
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
draw_score :: proc(score: [2]int) {
	font_size: i32 = 40
	score_text := rl.TextFormat("%d : %d", score[0], score[1])
	text_width := rl.MeasureText(score_text, font_size)

	x :=
		i32(state.arena.rect.x + (state.arena.rect.width / 2)) -
		(text_width / 2)
	y := i32(state.arena.rect.y) - font_size - 10

	rl.DrawText(score_text, x, y, font_size, rl.RAYWHITE)
}

/* CALCULATION PROCEDURES */

@(private)
determine_paddles_arena_collision :: proc() {
	top_boundary := rl.Rectangle {
		x      = state.arena.rect.x,
		y      = state.arena.rect.y,
		width  = state.arena.rect.width,
		height = 1,
	}

	bottom_boundary := rl.Rectangle {
		x      = state.arena.rect.x,
		y      = state.arena.rect.y + state.arena.rect.height - 1,
		width  = state.arena.rect.width,
		height = 1,
	}

	for &paddle in state.paddles {
		if rl.CheckCollisionRecs(paddle.rect, top_boundary) {
			paddle.rect.y = state.arena.rect.y
		}

		if rl.CheckCollisionRecs(paddle.rect, bottom_boundary) {
			paddle.rect.y =
				state.arena.rect.y +
				state.arena.rect.height -
				paddle.rect.height
		}
	}
}

@(private)
determine_arena_collision :: proc() {
	ball_center := state.ball.circle.center
	ball_radius := state.ball.circle.radius

	wall_thickness: f32 = 1

	top_wall := rl.Rectangle {
		x      = state.arena.rect.x,
		y      = state.arena.rect.y - wall_thickness,
		width  = state.arena.rect.width,
		height = wall_thickness,
	}

	bottom_wall := rl.Rectangle {
		x      = state.arena.rect.x,
		y      = state.arena.rect.y + state.arena.rect.height,
		width  = state.arena.rect.width,
		height = wall_thickness,
	}

	if rl.CheckCollisionCircleRec(ball_center, ball_radius, top_wall) ||
	   rl.CheckCollisionCircleRec(ball_center, ball_radius, bottom_wall) {
		state.ball.velocity.y *= -1
	}
}

@(private)
determine_paddle_collision :: proc() {
	for paddle in state.paddles {
		if rl.CheckCollisionCircleRec(
			state.ball.circle.center,
			state.ball.circle.radius,
			paddle.rect,
		) {
			state.ball.velocity.x *= -1
			state.ball.speed += 0.4
		}
	}
}

/* CREATE PROCEDURES */

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

	return Ball {
		circle = circle,
		velocity = generate_random_velocity(),
		speed = 2,
	}
}

/* RESET PROCEDURES */

@(private)
reset_game :: proc() {
	reset_ball()
	reset_paddles()
}

@(private)
reset_game_state :: proc() {
	state.score = [2]int{0, 0}
	state.countdown = 3
	LAST_UPDATE_TIME = rl.GetTime()
	reset_ball()
	reset_paddles()
}

@(private)
reset_ball :: proc() {
	state.ball = create_ball(state.arena)
}

@(private)
reset_paddles :: proc() {
	state.paddles = create_paddles(state.arena)
}

/* UTILITY PROCEDURES */

@(private)
generate_random_velocity :: proc() -> Vec2 {
	angle := rand.float32_range(-35, 35) * math.PI / 180
	velocity := Vec2{math.cos(angle), math.sin(angle)}

	if rand.int63() % 2 == 0 do velocity.x *= -1

	return velocity
}
