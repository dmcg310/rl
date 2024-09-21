package main

import rl "vendor:raylib"

// import "breakout"
// import "doom"
// import "pong"

// Game :: struct {
// 	name:   string,
// 	init:   proc(),
// 	update: proc(),
// 	draw:   proc(),
// }
//
// games := []Game {
// 	{name = "pong", init = pong.init, update = pong.update, draw = pong.draw},
// 	{
// 		name = "breakout",
// 		init = breakout.init,
// 		update = breakout.update,
// 		draw = breakout.draw,
// 	},
// 	{name = "doom", init = doom.init, update = doom.update, draw = doom.draw},
// }
//
// selected_game: ^Game
//

INITIAL_WIDTH, INITIAL_HEIGHT :: 1600, 900

MonitorDimensions :: struct {
	width:           f32,
	height:          f32,
	margin:          f32,
	frame_thickness: f32,
}

DesktopDimensions :: struct {
	margin: f32,
	rect:   rl.Rectangle,
}

monitor: MonitorDimensions
desktop: DesktopDimensions
window_width, window_height: i32

main :: proc() {
	initialize_window()
	defer rl.CloseWindow()

	window_width, window_height = INITIAL_WIDTH, INITIAL_HEIGHT

	update_dimensions()
	run_loop()
}

initialize_window :: proc() {
	rl.InitWindow(INITIAL_WIDTH, INITIAL_HEIGHT, "rl")
	rl.SetTargetFPS(160)
	rl.SetWindowState({.WINDOW_RESIZABLE})
}

run_loop :: proc() {
	for !rl.WindowShouldClose() {
		update()
		draw()
	}
}

update :: proc() {
	new_width := rl.GetScreenWidth()
	new_height := rl.GetScreenHeight()

	if new_width != window_width || new_height != window_height {
		window_width = new_width
		window_height = new_height
		update_dimensions()
	}
}

update_dimensions :: proc() {
	monitor, desktop = get_monitor_and_desktop_dimensions()
}

draw :: proc() {
	rl.BeginDrawing()
	defer rl.EndDrawing()
	rl.ClearBackground(rl.LIGHTGRAY)

	draw_monitor()
	draw_desk()
}

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
