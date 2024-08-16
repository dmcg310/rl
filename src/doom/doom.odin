package doom

import rl "vendor:raylib"

@(private)
State :: struct {
	camera: Camera3D,
	level:  Level,
}

@(private)
state: State

init :: proc() {
	state = State {
		camera = create_camera(),
		level  = create_level(),
	}
}

update :: proc() {
	update_camera(&state.camera)
}

draw :: proc() {
	rl.BeginMode3D(state.camera.handle)

	draw_level(&state.level)

	rl.EndMode3D()
}
