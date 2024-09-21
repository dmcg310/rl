package main

import rl "vendor:raylib"

import "breakout"
import "pong"

@(private = "file")
Game :: struct {
	name:        cstring,
	description: cstring,
	init:        proc(),
	update:      proc(),
	draw:        proc(),
}

@(private = "file")
games := []Game {
	{name = "Pong", init = pong.init, update = pong.update, draw = pong.draw},
	{
		name = "Breakout",
		init = breakout.init,
		update = breakout.update,
		draw = breakout.draw,
	},
}

@(private = "file")
selected_game: int = 0

@(private = "file")
INITIAL_WIDTH, INITIAL_HEIGHT :: 1600, 900

@(private = "file")
MonitorDimensions :: struct {
	width:           f32,
	height:          f32,
	margin:          f32,
	frame_thickness: f32,
}

@(private = "file")
DesktopDimensions :: struct {
	margin: f32,
	rect:   rl.Rectangle,
}

@(private = "file")
monitor: MonitorDimensions
@(private = "file")
desktop: DesktopDimensions
@(private = "file")
window_width, window_height: i32

init_launcher :: proc() {
	init_window()

	window_width, window_height = INITIAL_WIDTH, INITIAL_HEIGHT

	update_dimensions()
}

@(private = "file")
init_window :: proc() {
	rl.InitWindow(INITIAL_WIDTH, INITIAL_HEIGHT, "rl")
	rl.SetTargetFPS(160)
	rl.SetWindowState({.WINDOW_RESIZABLE})

}

run_launcher :: proc() {
	rl.GuiLoadStyle("assets/style_bluish.rgs")
	rl.GuiSetStyle(.DEFAULT, i32(rl.GuiDefaultProperty.TEXT_SIZE), 40)

	defer rl.CloseWindow()
	defer free_all(context.temp_allocator)

	for !rl.WindowShouldClose() {
		update_launcher()
		draw_launcher()
	}
}

@(private = "file")
update_launcher :: proc() {
	new_width := rl.GetScreenWidth()
	new_height := rl.GetScreenHeight()

	if new_width != window_width || new_height != window_height {
		window_width = new_width
		window_height = new_height
		update_dimensions()
	}
}

@(private = "file")
update_dimensions :: proc() {
	monitor, desktop = get_monitor_and_desktop_dimensions()
}

@(private = "file")
draw_launcher :: proc() {
	rl.BeginDrawing()
	defer rl.EndDrawing()
	rl.ClearBackground(rl.LIGHTGRAY)

	draw_monitor()
	draw_desk()
	draw_game_buttons()
}

@(private = "file")
draw_monitor :: proc() {
	// monitor stand
	stand_width := monitor.width / 5
	stand_height := monitor.height / 10
	rl.DrawRectangle(
		i32(monitor.margin + monitor.width / 2 - stand_width / 2),
		i32(monitor.margin + monitor.height),
		i32(stand_width),
		i32(stand_height),
		rl.BLACK,
	)

	// monitor frame (outer)
	rl.DrawRectangle(
		i32(monitor.margin),
		i32(monitor.margin),
		i32(monitor.width),
		i32(monitor.height),
		rl.DARKGRAY,
	)

	// monitor frame (inner bevel)
	rl.DrawRectangle(
		i32(monitor.margin + monitor.frame_thickness / 2),
		i32(monitor.margin + monitor.frame_thickness / 2),
		i32(monitor.width - monitor.frame_thickness),
		i32(monitor.height - monitor.frame_thickness),
		rl.GRAY,
	)

	// screen area
	rl.DrawRectangle(
		i32(monitor.margin + monitor.frame_thickness),
		i32(monitor.margin + monitor.frame_thickness),
		i32(monitor.width - 2 * monitor.frame_thickness),
		i32(monitor.height - 2 * monitor.frame_thickness),
		rl.BLACK,
	)

	// desktop area
	rl.DrawRectangleGradientH(
		i32(desktop.rect.x),
		i32(desktop.rect.y),
		i32(desktop.rect.width),
		i32(desktop.rect.height),
		rl.SKYBLUE,
		rl.DARKBLUE,
	)

	// power indicator
	rl.DrawRectangle(
		i32(monitor.margin + monitor.width - 40),
		i32(monitor.margin + monitor.height - 5),
		15,
		5,
		rl.LIME,
	)

	// monitor brand logo
	rl.DrawRectangle(
		i32(monitor.margin + monitor.width / 2 - 20),
		i32(monitor.margin + monitor.height - 7),
		40,
		7,
		rl.LIGHTGRAY,
	)
}

@(private = "file")
draw_desk :: proc() {
	desk_start_y := monitor.margin + monitor.height + monitor.height / 10
	desk_color := rl.BEIGE

	rl.DrawRectangle(
		0,
		i32(desk_start_y),
		window_width,
		i32(f32(window_height) - desk_start_y),
		desk_color,
	)

	edge_thickness: i32 = 10
	rl.DrawRectangle(
		0,
		i32(desk_start_y),
		window_width,
		edge_thickness,
		rl.BROWN,
	)
}

@(private = "file")
draw_game_buttons :: proc() {
	padding: f32 = 40
	gap: f32 = 10

	available_width := desktop.rect.width - (2 * padding)
	available_height := desktop.rect.height - (2 * padding)

	num_rows := (len(games) + 1) / 2

	button_width := (available_width - gap) / 2
	button_height :=
		(available_height - (f32(num_rows - 1) * gap)) / f32(num_rows)

	for game, i in games {
		column := i % 2
		row := i / 2

		x := desktop.rect.x + padding + f32(column) * (button_width + gap)
		y := desktop.rect.y + padding + f32(row) * (button_height + gap)

		button_rect := rl.Rectangle {
			x      = x,
			y      = y,
			width  = button_width,
			height = button_height,
		}

		if rl.GuiButton(button_rect, game.name) {
			selected_game = i
		}
	}

	if selected_game >= 0 && selected_game < len(games) {
		// do something with selected game
	}
}

@(private = "file")
get_monitor_and_desktop_dimensions :: proc(
) -> (
	MonitorDimensions,
	DesktopDimensions,
) {
	width_ratio := f32(window_width) / f32(INITIAL_WIDTH)
	height_ratio := f32(window_height) / f32(INITIAL_HEIGHT)
	scale := min(width_ratio, height_ratio)

	monitor_margin := 100 * scale
	frame_thickness := 20 * scale

	monitor_dimensions := MonitorDimensions {
		f32(window_width) - 2 * monitor_margin,
		(f32(window_height) - 2 * monitor_margin) * 9 / 10,
		monitor_margin,
		frame_thickness,
	}

	desktop_margin: f32 = 0
	desktop_rect := rl.Rectangle {
		monitor_margin + frame_thickness + desktop_margin,
		monitor_margin + frame_thickness + desktop_margin,
		monitor_dimensions.width - 2 * (frame_thickness + desktop_margin),
		monitor_dimensions.height - 2 * (frame_thickness + desktop_margin),
	}
	desktop_dimensions := DesktopDimensions{desktop_margin, desktop_rect}

	return monitor_dimensions, desktop_dimensions
}
