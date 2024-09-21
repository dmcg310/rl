package main

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

main :: proc() {
	init_launcher()
	run_launcher()
}
