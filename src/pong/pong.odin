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

PongState :: struct {
	score:   [2]int,
	arena:   Arena,
	paddles: [2]Paddle,
}

state: PongState

init :: proc() {
	arena := create_arena()
	paddles := create_paddles(arena)
	state = PongState {
		arena   = arena,
		paddles = paddles,
	}
}

update :: proc() {
	paddle_left := &state.paddles[0]
	paddle_right := &state.paddles[1]

	if rl.IsKeyDown(.W) do paddle_left.rect.y -= paddle_left.speed
	if rl.IsKeyDown(.S) do paddle_left.rect.y += paddle_left.speed

	if rl.IsKeyDown(.UP) do paddle_right.rect.y -= paddle_right.speed
	if rl.IsKeyDown(.DOWN) do paddle_right.rect.y += paddle_right.speed
}

draw :: proc() {
	draw_arena()
	draw_paddles(state.paddles)
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
