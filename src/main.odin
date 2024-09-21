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

WINDOW_WIDTH, WINDOW_HEIGHT :: 1600, 900

MonitorDimensions :: struct {
	width:           i32,
	height:          i32,
	margin:          i32,
	frame_thickness: i32,
}

DesktopDimensions :: struct {
	margin: i32,
	rect:   rl.Rectangle,
}

monitor: MonitorDimensions
desktop: DesktopDimensions

main :: proc() {
	initialize_window()
	defer rl.CloseWindow()

	monitor, desktop = get_monitor_and_desktop_dimensions()

	run_loop()
}

initialize_window :: proc() {
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "rl")
	rl.SetTargetFPS(160)
}

run_loop :: proc() {
	for !rl.WindowShouldClose() {
		update()
		draw()
	}
}

update :: proc() {}

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
		monitor.margin + monitor.width / 2 - stand_width / 2,
		monitor.margin + monitor.height,
		stand_width,
		stand_height,
		rl.BLACK,
	)

	// monitor frame (outer)
	rl.DrawRectangle(
		monitor.margin,
		monitor.margin,
		monitor.width,
		monitor.height,
		rl.DARKGRAY,
	)

	// monitor frame (inner bevel)
	rl.DrawRectangle(
		monitor.margin + monitor.frame_thickness / 2,
		monitor.margin + monitor.frame_thickness / 2,
		monitor.width - monitor.frame_thickness,
		monitor.height - monitor.frame_thickness,
		rl.GRAY,
	)

	// screen area
	rl.DrawRectangle(
		monitor.margin + monitor.frame_thickness,
		monitor.margin + monitor.frame_thickness,
		monitor.width - 2 * monitor.frame_thickness,
		monitor.height - 2 * monitor.frame_thickness,
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
		monitor.margin + monitor.width - 40,
		monitor.margin + monitor.height - 5,
		15,
		5,
		rl.LIME,
	)

	// monitor brand logo
	rl.DrawRectangle(
		monitor.margin + monitor.width / 2 - 20,
		monitor.margin + monitor.height - 7,
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
		desk_start_y,
		WINDOW_WIDTH,
		WINDOW_HEIGHT - desk_start_y,
		desk_color,
	)

	edge_thickness: i32 = 10
	rl.DrawRectangle(0, desk_start_y, WINDOW_WIDTH, edge_thickness, rl.BROWN)
}

get_monitor_and_desktop_dimensions :: proc(
) -> (
	MonitorDimensions,
	DesktopDimensions,
) {
	monitor_margin: i32 = 100
	frame_thickness: i32 = 20

	monitor_dimensions := MonitorDimensions {
		WINDOW_WIDTH - 2 * monitor_margin,
		(WINDOW_HEIGHT - 2 * monitor_margin) * 9 / 10,
		monitor_margin,
		frame_thickness,
	}

	desktop_margin: i32 = 0
	desktop_rect := rl.Rectangle {
		f32(monitor_margin + frame_thickness + desktop_margin),
		f32(monitor_margin + frame_thickness + desktop_margin),
		f32(monitor_dimensions.width - 2 * (frame_thickness + desktop_margin)),
		f32(
			monitor_dimensions.height - 2 * (frame_thickness + desktop_margin),
		),
	}
	desktop_dimensions := DesktopDimensions{desktop_margin, desktop_rect}

	return monitor_dimensions, desktop_dimensions
}
