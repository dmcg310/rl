package doom

import rl "vendor:raylib"


State :: struct {
	camera: Camera3D,
}

state: State

MAX_COLUMNS :: 20

heights: [MAX_COLUMNS]f32
positions: [MAX_COLUMNS]Vec3
colors: [MAX_COLUMNS]rl.Color

init :: proc() {
	state = State {
		camera = create_camera(),
	}

	heights = 0
	positions = 0
	colors = 0

	for i := 0; i < MAX_COLUMNS; i += 1 {
		heights[i] = f32(rl.GetRandomValue(1, 12))
		positions[i] = Vec3 {
			f32(rl.GetRandomValue(-15, 15)),
			heights[i] / 2.0,
			f32(rl.GetRandomValue(-15, 15)),
		}
		colors[i] = rl.Color {
			u8(rl.GetRandomValue(20, 255)),
			u8(rl.GetRandomValue(10, 55)),
			30,
			255,
		}
	}

}

update :: proc() {
	update_camera(&state.camera)
}

draw :: proc() {
	rl.BeginMode3D(state.camera.handle)

	rl.DrawPlane(Vec3{0.0, 0.0, 0.0}, Vec2{32.0, 32.0}, rl.LIGHTGRAY)
	rl.DrawCube(Vec3{-16.0, 2.5, 0.0}, 1.0, 5.0, 32.0, rl.BLUE)
	rl.DrawCube(Vec3{16.0, 2.5, 0.0}, 1.0, 5.0, 32.0, rl.LIME)
	rl.DrawCube(Vec3{0.0, 2.5, 16.0}, 32.0, 5.0, 1.0, rl.GOLD)

	for i := 0; i < MAX_COLUMNS; i += 1 {
		rl.DrawCube(positions[i], 2.0, heights[i], 2.0, colors[i])
		rl.DrawCubeWires(positions[i], 2.0, heights[i], 2.0, rl.MAROON)
	}

	rl.EndMode3D()
}
