package breakout

import "core:math"
import "core:fmt"
import "core:math/rand"
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
	rect:      rl.Rectangle,
	speed:     f32,
	direction: f32,
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
BreakoutState :: struct {
	arena:      Arena,
	paddle:     Paddle,
	ball:       Ball,
	game_state: GameState,
}

@(private)
state: BreakoutState

@(private)
BORDER_THICKNESS: f32 = 10

init :: proc() {
	arena := create_arena()
	paddle := create_paddle(arena)
	ball := create_ball(arena)

	state = BreakoutState{arena, paddle, ball, .Playing}
}

/* UPDATE PROCEDURES */

update :: proc() {
	switch state.game_state {
	case .StartScreen:
	// update_start_screen()
	case .Countdown:
	// update_countdown()
	case .Playing:
		update_game()
	case .GameOver:
	// update_game_over()
	}
}

@(private)
update_game :: proc() {
	update_paddle()
	update_ball()
}

@(private)
update_paddle :: proc() {
	paddle := &state.paddle
	paddle.direction = 0

	if rl.IsKeyDown(.A) do paddle.direction = -1
	if rl.IsKeyDown(.D) do paddle.direction = 1

	if rl.IsKeyDown(.LEFT) do paddle.direction = -1
	if rl.IsKeyDown(.RIGHT) do paddle.direction = 1

	paddle.rect.x += paddle.direction * paddle.speed

	determine_paddle_arena_collision()
}

@(private)
update_ball :: proc() {
	ball := &state.ball
    ball.circle.center.x += ball.velocity.x * ball.speed
    ball.circle.center.y += ball.velocity.y * ball.speed

    determine_arena_collision()
    determine_paddle_collision()
}

/* DRAW PROCEDURS */

draw :: proc() {
	rl.ClearBackground(rl.GRAY)

	switch state.game_state {
	case .StartScreen:
	// draw_start_screen()
	case .Countdown:
	// draw_countdown()
	case .Playing:
		draw_game()
	case .GameOver:
	// draw_game_over()
	}
}

@(private)
draw_game :: proc() {
	draw_arena()
	draw_paddle()
	draw_ball()
}

@(private)
draw_arena :: proc() {
	rl.DrawRectangleRec(state.arena.rect, rl.DARKGRAY)

	// Draw top border
	rl.DrawRectangle(
		i32(state.arena.rect.x - BORDER_THICKNESS),
		i32(state.arena.rect.y - BORDER_THICKNESS),
		i32(state.arena.rect.width + 2 * BORDER_THICKNESS),
		i32(BORDER_THICKNESS),
		rl.RAYWHITE,
	)

	// Draw bottom border
	rl.DrawRectangle(
		i32(state.arena.rect.x - BORDER_THICKNESS),
		i32(state.arena.rect.y + state.arena.rect.height),
		i32(state.arena.rect.width + 2 * BORDER_THICKNESS),
		i32(BORDER_THICKNESS),
		rl.RAYWHITE,
	)

	// Draw left border
	rl.DrawRectangle(
		i32(state.arena.rect.x - BORDER_THICKNESS),
		i32(state.arena.rect.y),
		i32(BORDER_THICKNESS),
		i32(state.arena.rect.height),
		rl.RAYWHITE,
	)

	// Draw right border
	rl.DrawRectangle(
		i32(state.arena.rect.x + state.arena.rect.width),
		i32(state.arena.rect.y),
		i32(BORDER_THICKNESS),
		i32(state.arena.rect.height),
		rl.RAYWHITE,
	)
}

@(private)
draw_paddle :: proc() {
	rl.DrawRectangleRec(state.paddle.rect, rl.SKYBLUE)
}

@(private)
draw_ball :: proc() {
	rl.DrawCircleV(
		state.ball.circle.center,
		state.ball.circle.radius,
		rl.RAYWHITE,
	)
}

/* CALCULATION PROCEDURES */

@(private)
determine_paddle_arena_collision :: proc() {
	left_boundary := state.arena.rect.x
	right_boundary :=
		state.arena.rect.x + state.arena.rect.width - state.paddle.rect.width

	if state.paddle.rect.x < left_boundary {
		state.paddle.rect.x = left_boundary
	}

	if state.paddle.rect.x > right_boundary {
		state.paddle.rect.x = right_boundary
	}
}

@(private)
determine_arena_collision :: proc() {
    ball := &state.ball
    arena := state.arena

    // Left and right walls
    if ball.circle.center.x - ball.circle.radius <= arena.rect.x ||
       ball.circle.center.x + ball.circle.radius >= arena.rect.x + arena.rect.width {
        ball.velocity.x *= -1
    }

    // Top wall
    if ball.circle.center.y - ball.circle.radius <= arena.rect.y {
        ball.velocity.y *= -1
    }

	// TEMPORARY
    if ball.circle.center.y + ball.circle.radius >= arena.rect.y + arena.rect.height {
        ball.velocity.y *= -1
    }
}

@(private)
determine_paddle_collision :: proc() {
    ball := &state.ball
    paddle := &state.paddle

    if rl.CheckCollisionCircleRec(
        ball.circle.center,
        ball.circle.radius,
        paddle.rect,
    ) {
        ball.velocity.y *= -1

        paddle_center := paddle.rect.x + paddle.rect.width / 2
        hit_position := (ball.circle.center.x - paddle_center) / (paddle.rect.width / 2)
        ball.velocity.x = hit_position

        length := math.sqrt(ball.velocity.x * ball.velocity.x + ball.velocity.y * ball.velocity.y)
        ball.velocity.x /= length
        ball.velocity.y /= length
    }
}

/* Create PROCEDURES */

@(private)
create_arena :: proc() -> Arena {
	screen_width := f32(rl.GetScreenWidth())
	screen_height := f32(rl.GetScreenHeight())

	rect_width := screen_width * 0.75
	rect_height := screen_height * 0.75

	rect_x := (screen_width - rect_width) * 0.5
	rect_y := (screen_height - rect_height) * 0.5

	return Arena{rect = {rect_x, rect_y, rect_width, rect_height}}
}

@(private)
create_paddle :: proc(arena: Arena) -> Paddle {
	paddle_width: f32 = 100
	paddle_height: f32 = 20
	paddle_offset: f32 = 20
	paddle_speed: f32 = 3

	return Paddle {
		rect = {
			x = arena.rect.x + (arena.rect.width - paddle_width) * 0.5,
			y = arena.rect.y +
			arena.rect.height -
			paddle_height -
			paddle_offset,
			width = paddle_width,
			height = paddle_height,
		},
		speed = paddle_speed,
		direction = 0,
	}
}

@(private)
create_ball :: proc(arena: Arena) -> Ball {
    circle_radius: f32 = 10

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
        speed = 5,
    }
}

/* UTILITY PROCEDURES */

@(private)
generate_random_velocity :: proc() -> Vec2 {
    angle := rand.float32_range(-60, 60) * math.PI / 180
    return Vec2{math.sin(angle), math.cos(angle)}
}
