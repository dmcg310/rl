package main

import "core:fmt"
import "core:os"
import rl "vendor:raylib"

Game :: struct {
	name:   string,
	init:   proc(),
	update: proc(),
	draw:   proc(),
}

games := []Game{{name = "pong", init = nil, update = nil, draw = nil}}

selected_game: ^Game

main :: proc() {
	if !parse_arguments() {
		return
	}

	initialize_window()
	defer rl.CloseWindow()

	run_game_loop()
}

parse_arguments :: proc() -> bool {
	args := os.args[1:]
	if len(args) == 0 {
		display_usage()

		return false
	}

	game_name := args[0]
	selected_game = find_game(game_name)

	if selected_game == nil {
		fmt.printf("Unknown game: %s\n", game_name)
		display_available_games()

		return false
	}

	return true
}

display_usage :: proc() {
	fmt.println("Usage: ./exe <game_name>")
	display_available_games()
}

find_game :: proc(name: string) -> ^Game {
	for &game in games {
		if game.name == name {
			return &game
		}
	}

	return nil
}

initialize_window :: proc() {
	rl.InitWindow(1600, 900, "rl")
	rl.SetTargetFPS(160)
}

run_game_loop :: proc() {
	if selected_game.init != nil {
		selected_game.init()
	}

	for !rl.WindowShouldClose() {
		update_game()
		draw_game()
	}
}

update_game :: proc() {
	if selected_game.update != nil {
		selected_game.update()
	}
}

draw_game :: proc() {
	rl.BeginDrawing()
	defer rl.EndDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	if selected_game.draw != nil {
		selected_game.draw()
	} else {
		rl.DrawText("Game not implemented yet", 600, 400, 20, rl.BLACK)
	}
}

display_available_games :: proc() {
	fmt.println("Available games:")
	for game in games {
		fmt.printf("- %s\n", game.name)
	}
}
