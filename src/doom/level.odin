package doom

import rl "vendor:raylib"

@(private = "file")
MAX_WALLS, MAX_SPAWN_POINTS :: 100, 10

@(private = "file")
WALL_POS_Y, WALL_HEIGHT_Y :: 2, 4

@(private = "file")
TILE_SIZE :: 6

@(private = "file")
LEVEL_WIDTH, LEVEL_HEIGHT :: 10, 10

Level :: struct {
	floor:             Floor,
	walls:             [MAX_WALLS]Wall,
	wall_count:        int,
	spawn_points:      [MAX_SPAWN_POINTS]SpawnPoint,
	spawn_point_count: int,
}

@(private = "file")
Floor :: struct {
	position: Vec3,
	size:     Vec2,
	color:    Color,
}

@(private = "file")
Wall :: struct {
	position: Vec3,
	size:     Vec3,
	color:    Color,
}

@(private = "file")
SpawnPoint :: struct {
	position:  Vec3,
	is_player: bool,
}

draw_level :: proc(level: ^Level) {
	rl.DrawPlane(level.floor.position, level.floor.size, level.floor.color)

	for wall in level.walls {
		rl.DrawCubeV(wall.position, wall.size, wall.color)
	}
}

create_level :: proc() -> Level {
	levelData: [10][10]int = {
		{1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
		{1, 0, 0, 0, 0, 0, 0, 0, 0, 1},
		{1, 0, 0, 0, 0, 0, 0, 0, 0, 1},
		{1, 0, 0, 1, 1, 0, 0, 0, 0, 1},
		{1, 0, 0, 1, 0, 0, 0, 1, 0, 1},
		{1, 0, 0, 1, 0, 0, 0, 1, 0, 1},
		{1, 0, 0, 0, 0, 0, 0, 1, 0, 1},
		{1, 0, 0, 0, 0, 1, 1, 1, 0, 1},
		{1, 0, 0, 0, 0, 0, 0, 0, 0, 1},
		{1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	}

	level := Level{}
	level.wall_count = 0
	level.spawn_point_count = 0

	level.floor = create_floor(
		Vec3{0, 0, 0},
		Vec2{TILE_SIZE * LEVEL_WIDTH, TILE_SIZE * LEVEL_HEIGHT},
		rl.WHITE,
	)

	for y in 0 ..< LEVEL_HEIGHT {
		for x in 0 ..< LEVEL_WIDTH {
			if levelData[y][x] == 1 {
				position := Vec3 {
					f32(x) * TILE_SIZE - (f32(LEVEL_WIDTH) * TILE_SIZE / 2),
					WALL_POS_Y,
					f32(y) * TILE_SIZE - (f32(LEVEL_HEIGHT) * TILE_SIZE / 2),
				}

				level.walls[level.wall_count] = create_wall(
					&level,
					position,
					Vec3{TILE_SIZE, WALL_HEIGHT_Y, TILE_SIZE},
					rl.DARKGRAY,
				)
			}
		}
	}

	level.spawn_points[level.spawn_point_count] = create_spawn_point(
		&level,
		Vec3{0, 0, 0},
		true,
	)

	return level
}

@(private = "file")
create_floor :: proc(position: Vec3, size: Vec2, color: Color) -> Floor {
	return Floor{position, size, color}
}

@(private = "file")
create_wall :: proc(
	level: ^Level,
	position: Vec3,
	size: Vec3,
	color: Color,
) -> Wall {
	level.wall_count += 1
	return Wall{position, size, color}
}

@(private = "file")
create_spawn_point :: proc(
	level: ^Level,
	position: Vec3,
	is_player: bool,
) -> SpawnPoint {
	level.spawn_point_count += 1
	return SpawnPoint{position, is_player}
}
