package doom

import rl "vendor:raylib"

Camera3D :: struct {
	handle: rl.Camera3D,
	mode:   rl.CameraMode,
}

create_camera :: proc() -> Camera3D {
	rl.DisableCursor()

	return Camera3D {
		rl.Camera3D {
			position = Vec3{0.0, 2.0, 4.0},
			target = Vec3{0.0, 2.0, 0.0},
			up = Vec3{0.0, 1.0, 0.0},
			fovy = 60.0,
			projection = .PERSPECTIVE,
		},
		.FIRST_PERSON,
	}
}

update_camera :: proc(camera: ^Camera3D) {
	rl.UpdateCamera(&camera.handle, camera.mode)
}
