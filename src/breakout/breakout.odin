package breakout

import "core:math"
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
	LevelComplete,
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
Brick :: struct {
	rect:   rl.Rectangle,
	color:  rl.Color,
	active: bool,
}

@(private)
BreakoutState :: struct {
	score:        u16,
	lives:        u8,
	arena:        Arena,
	paddle:       Paddle,
	ball:         Ball,
	bricks:       []Brick,
	bricks_alive: u16,
	game_state:   GameState,
	countdown:    u8,
}

@(private)
state: BreakoutState

@(private)
LAST_UPDATE_TIME := rl.GetTime()

@(private)
ARENA_BORDER_THICKNESS: f32 = 10

@(private)
BRICK_BORDER_THICKNESS: f32 = 1

@(private)
DEFAULT_LIVES: u8 = 3

init :: proc() {
	score: u16 = 0
	lives := DEFAULT_LIVES
	arena := create_arena()
	paddle := create_paddle(arena)
	ball := create_ball(arena)
	bricks := create_bricks(arena)
	bricks_alive: u16 = 128
	starting_state: GameState = .StartScreen
	countdown: u8 = 3

	state = BreakoutState {
		score,
		lives,
		arena,
		paddle,
		ball,
		bricks,
		bricks_alive,
		starting_state,
		countdown,
	}
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
	case .LevelComplete:
		update_level_complete()
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
	update_paddle()
	update_ball()
	update_bricks()

	if state.bricks_alive == 0 {
		state.game_state = .LevelComplete
	}
}

@(private)
update_game_over :: proc() {
	if rl.IsKeyPressed(.SPACE) {
		reset_game_completely()
		state.game_state = .Countdown
	}
}

@(private)
update_level_complete :: proc() {
	if rl.IsKeyPressed(.SPACE) {
		if state.lives < 5 {
			state.lives += 1
		}

		reset_game_state()
		state.game_state = .Countdown
		state.ball.speed += 0.5
	}
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

@(private)
update_bricks :: proc() {
	update_score(determine_brick_collision())
}

@(private)
update_score :: proc(brick: Brick) {
	switch (brick.color) {
	case rl.GREEN:
		state.score += 1
	case rl.YELLOW:
		state.score += 3
	case rl.ORANGE:
		state.score += 5
	case rl.RED:
		state.score += 7
	case:
		return
	}
}

/* DRAW PROCEDURS */

draw :: proc() {
	rl.ClearBackground(rl.GRAY)

	switch state.game_state {
	case .StartScreen:
		draw_start_screen()
	case .Countdown:
		draw_countdown()
	case .Playing:
		draw_game()
	case .GameOver:
		draw_game_over()
	case .LevelComplete:
		draw_level_complete()
	}
}

@(private)
draw_start_screen :: proc() {
	draw_game()


	title_text: cstring = "BREAKOUT"
	font_size: i32 = 90
	text_width := rl.MeasureText(title_text, font_size)

	rl.DrawText(
		title_text,
		i32(rl.GetScreenWidth() / 2 - text_width / 2),
		125,
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
		rl.RAYWHITE,
	)
}

@(private)
draw_countdown :: proc() {
	draw_game()

	countdown_bg_width: i32 = 200
	countdown_bg_height: i32 = 150
	countdown_bg_x := i32(rl.GetScreenWidth() / 2 - countdown_bg_width / 2)
	countdown_bg_y := i32(rl.GetScreenHeight() / 2 - countdown_bg_height / 2)
	rl.DrawRectangle(
		countdown_bg_x,
		countdown_bg_y,
		countdown_bg_width,
		countdown_bg_height,
		rl.ColorAlpha(rl.BLACK, 0.5),
	)

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
	draw_paddle()
	draw_ball()
	draw_bricks()
	draw_score()
	draw_lives()
}

@(private)
draw_game_over :: proc() {
	draw_game()

	game_over_text: cstring = "GAME OVER"
	font_size: i32 = 90
	text_width := rl.MeasureText(game_over_text, font_size)
	rl.DrawText(
		game_over_text,
		i32(rl.GetScreenWidth() / 2 - text_width / 2),
		125,
		font_size,
		rl.WHITE,
	)

	score_text := rl.TextFormat("Final Score: %d", i32(state.score))
	score_font_size: i32 = 40
	score_text_width := rl.MeasureText(score_text, score_font_size)
	rl.DrawText(
		score_text,
		i32(rl.GetScreenWidth() / 2 - score_text_width / 2),
		250,
		score_font_size,
		rl.SKYBLUE,
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
draw_level_complete :: proc() {
	draw_game()

	level_complete_text: cstring = "LEVEL COMPLETE!"
	font_size: i32 = 60
	text_width := rl.MeasureText(level_complete_text, font_size)
	rl.DrawText(
		level_complete_text,
		i32(rl.GetScreenWidth() / 2 - text_width / 2),
		125,
		font_size,
		rl.GREEN,
	)

	score_text := rl.TextFormat("Current Score: %d", i32(state.score))
	score_font_size: i32 = 40
	score_text_width := rl.MeasureText(score_text, score_font_size)
	rl.DrawText(
		score_text,
		i32(rl.GetScreenWidth() / 2 - score_text_width / 2),
		250,
		score_font_size,
		rl.SKYBLUE,
	)

	restart_text: cstring = "Press SPACE for next level"
	restart_font_size: i32 = 30
	restart_text_width := rl.MeasureText(restart_text, restart_font_size)
	rl.DrawText(
		restart_text,
		i32(rl.GetScreenWidth() / 2 - restart_text_width / 2),
		300,
		restart_font_size,
		rl.WHITE,
	)
}

@(private)
draw_arena :: proc() {
	rl.DrawRectangleRec(state.arena.rect, rl.DARKGRAY)

	// Draw top border
	rl.DrawRectangle(
		i32(state.arena.rect.x - ARENA_BORDER_THICKNESS),
		i32(state.arena.rect.y - ARENA_BORDER_THICKNESS),
		i32(state.arena.rect.width + 2 * ARENA_BORDER_THICKNESS),
		i32(ARENA_BORDER_THICKNESS),
		rl.RAYWHITE,
	)

	// Draw bottom border
	rl.DrawRectangle(
		i32(state.arena.rect.x - ARENA_BORDER_THICKNESS),
		i32(state.arena.rect.y + state.arena.rect.height),
		i32(state.arena.rect.width + 2 * ARENA_BORDER_THICKNESS),
		i32(ARENA_BORDER_THICKNESS),
		rl.RAYWHITE,
	)

	// Draw left border
	rl.DrawRectangle(
		i32(state.arena.rect.x - ARENA_BORDER_THICKNESS),
		i32(state.arena.rect.y),
		i32(ARENA_BORDER_THICKNESS),
		i32(state.arena.rect.height),
		rl.RAYWHITE,
	)

	// Draw right border
	rl.DrawRectangle(
		i32(state.arena.rect.x + state.arena.rect.width),
		i32(state.arena.rect.y),
		i32(ARENA_BORDER_THICKNESS),
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

@(private)
draw_bricks :: proc() {
	for brick in state.bricks {
		if brick.active {
			rl.DrawRectangleRec(brick.rect, brick.color)
			rl.DrawRectangleLinesEx(
				brick.rect,
				f32(BRICK_BORDER_THICKNESS),
				rl.BLACK,
			)
		}
	}
}

@(private)
draw_score :: proc() {
	font_size: i32 = 70
	score_text := rl.TextFormat("%d", state.score)
	text_width := rl.MeasureText(score_text, font_size)

	x :=
		i32(state.arena.rect.x + (state.arena.rect.width / 2)) -
		(text_width / 2)
	y := i32(state.arena.rect.y) - font_size - 10

	rl.DrawText(score_text, x, y, font_size, rl.RAYWHITE)
}

@(private)
draw_lives :: proc() {
	font_size: i32 = 50
	lives_text := rl.TextFormat("Lives: %d", state.lives)
	text_width := rl.MeasureText(lives_text, font_size)

	x :=
		i32(state.arena.rect.x + (state.arena.rect.width / 2)) -
		(text_width / 2)
	y := i32(state.arena.rect.y + state.arena.rect.height) + 20

	rl.DrawText(lives_text, x, y, font_size, rl.RED)
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
	   ball.circle.center.x + ball.circle.radius >=
		   arena.rect.x + arena.rect.width {
		ball.velocity.x *= -1
	}

	// Top wall
	if ball.circle.center.y - ball.circle.radius <= arena.rect.y {
		ball.velocity.y *= -1
	}

	// Bottom wall
	if ball.circle.center.y + ball.circle.radius >=
	   arena.rect.y + arena.rect.height {
		if state.lives == 0 {
			state.game_state = .GameOver
			return
		}

		state.lives -= 1
		reset_game()
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
		paddle_center := paddle.rect.x + paddle.rect.width / 2
		hit_position :=
			(ball.circle.center.x - paddle_center) / (paddle.rect.width / 2)

		angle := hit_position * 60 * math.PI / 180

		ball.velocity.x = math.sin(angle)
		ball.velocity.y = -math.abs(math.cos(angle))

		length := math.sqrt(
			ball.velocity.x * ball.velocity.x +
			ball.velocity.y * ball.velocity.y,
		)

		ball.velocity.x /= length
		ball.velocity.y /= length
	}
}

@(private)
determine_brick_collision :: proc() -> Brick {
	for &brick in state.bricks {
		if brick.active &&
		   rl.CheckCollisionCircleRec(
			   state.ball.circle.center,
			   state.ball.circle.radius,
			   brick.rect,
		   ) {
			brick.active = false
			state.bricks_alive -= 1

			state.ball.velocity *= -1
			state.ball.speed += 0.2

			return brick
		}
	}

	return {}
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
	paddle_width: f32 = 130
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
		speed = 3,
	}
}

@(private)
create_bricks :: proc(arena: Arena) -> []Brick {
	bricks: [dynamic]Brick = {}

	rows := 8
	cols := 16
	margin: f32 = 5

	brick_width := (arena.rect.width - margin * 2) / f32(cols)
	brick_height: f32 = 25

	start_y := arena.rect.y + 20

	for row_idx := 0; row_idx < rows; row_idx += 1 {
		for col_idx := 0; col_idx < cols; col_idx += 1 {
			x := arena.rect.x + margin + f32(col_idx) * brick_width
			y := start_y + f32(row_idx) * brick_height

			brick_color: rl.Color

			switch row_idx {
			case 0:
				fallthrough
			case 1:
				brick_color = rl.RED
			case 2:
				fallthrough
			case 3:
				brick_color = rl.ORANGE
			case 4:
				fallthrough
			case 5:
				brick_color = rl.YELLOW
			case 6:
				fallthrough
			case 7:
				brick_color = rl.GREEN
			}

			append(
				&bricks,
				Brick {
					rect = {
						x = x,
						y = y,
						width = brick_width,
						height = brick_height,
					},
					color = brick_color,
					active = true,
				},
			)
		}
	}

	return bricks[:]
}

/* RESET PROCEDURES */

@(private)
reset_game :: proc() {
	LAST_UPDATE_TIME = rl.GetTime()
	reset_ball()
	reset_paddle()
	state.countdown = 3
	state.game_state = .Countdown
}

@(private)
reset_game_completely :: proc() {
	state.score = 0
	state.lives = DEFAULT_LIVES
	reset_game_state()
}

@(private)
reset_game_state :: proc() {
	LAST_UPDATE_TIME = rl.GetTime()
	state.countdown = 3
	reset_ball()
	reset_paddle()
	reset_bricks()
}

@(private)
reset_ball :: proc() {
	state.ball = create_ball(state.arena)
}

@(private)
reset_paddle :: proc() {
	state.paddle = create_paddle(state.arena)
}

@(private)
reset_bricks :: proc() {
	state.bricks = create_bricks(state.arena)
	state.bricks_alive = u16(len(state.bricks))
}

/* UTILITY PROCEDURES */

@(private)
generate_random_velocity :: proc() -> Vec2 {
	angle := rand.float32_range(-60, 60) * math.PI / 180
	return Vec2{math.sin(angle), math.cos(angle)}
}
