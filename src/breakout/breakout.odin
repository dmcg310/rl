package breakout

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
BreakoutState :: struct {
	arena:      Arena,
	paddle:     Paddle,
	game_state: GameState,
}

@(private)
state: BreakoutState

@(private)
BORDER_THICKNESS: f32 = 10

init :: proc() {
	arena := create_arena()
	paddle := create_paddle(arena)

	state = BreakoutState{arena, paddle, .Playing}
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
