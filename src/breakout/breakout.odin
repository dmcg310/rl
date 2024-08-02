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
BreakoutState :: struct {
	arena: Arena,
	game_state: GameState,
}

@(private)
state: BreakoutState

@(private)
BORDER_THICKNESS: f32 = 10

init :: proc() {
	arena := create_arena()

	state = BreakoutState{arena, .Playing}
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

update_game :: proc() {
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

/* CREATE PROCEDURES */
create_arena :: proc() -> Arena {
	screen_width := f32(rl.GetScreenWidth())
	screen_height := f32(rl.GetScreenHeight())

	rect_width := screen_width * 0.75
	rect_height := screen_height * 0.75

	rect_x := (screen_width - rect_width) * 0.5
	rect_y := (screen_height - rect_height) * 0.5

	return Arena{rect = {rect_x, rect_y, rect_width, rect_height}}
}
