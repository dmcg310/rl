package doom

import rl "vendor:raylib"

Key :: rl.KeyboardKey

is_key_pressed :: proc(key: Key) -> bool {
	return rl.IsKeyPressed(key)
}
