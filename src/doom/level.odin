package doom

import rl "vendor:raylib"

@(private = "file")
MAX_WALLS :: 100

@(private = "file")
MAX_SPAWN_POINTS :: 10

@(private = "file")
WALL_POS_Y, WALL_HEIGHT_Y, WALL_WIDTH :: 2, 4, 0.5

@(private = "file")
TILE_SIZE :: 16

Level :: struct {
	name:              string,
	floor:             Floor,
	walls:             [MAX_WALLS]Wall,
	wall_count:        int,
	spawn_points:      [MAX_SPAWN_POINTS]SpawnPoint,
	spawn_point_count: int,
}

LevelType :: enum {
	Basic,
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

/* DRAWING PROCEDURES */

draw_level :: proc(level: ^Level) {
	rl.DrawPlane(level.floor.position, level.floor.size, level.floor.color)

	for wall in level.walls {
		rl.DrawCubeV(wall.position, wall.size, wall.color)
	}
}

/* CREATION PROCEDURES */

create_level :: proc(name: string, type: LevelType) -> Level {
	switch type {
	case .Basic:
		return create_basic_level(name)
	case:
		return Level{}
	}
}

@(private = "file")
create_basic_level :: proc(name: string) -> Level {
	level := Level{}
	level.name = name
	level.wall_count = 0
	level.spawn_point_count = 0

	level.floor = create_floor(
		Vec3{0, 0, 0},
		Vec2{TILE_SIZE, TILE_SIZE},
		rl.GRAY,
	)

	// left wall
	level.walls[level.wall_count] = create_wall(
		&level,
		Vec3{-(TILE_SIZE / 2), WALL_POS_Y, 0}, // position
		Vec3{WALL_WIDTH, WALL_HEIGHT_Y, TILE_SIZE}, // size
		rl.DARKGRAY,
	)

	// right wall
	level.walls[level.wall_count] = create_wall(
		&level,
		Vec3{TILE_SIZE / 2, WALL_POS_Y, 0}, // position
		Vec3{WALL_WIDTH, WALL_HEIGHT_Y, TILE_SIZE}, // size
		rl.DARKGRAY,
	)

	// front wall
	level.walls[level.wall_count] = create_wall(
		&level,
		Vec3{0, WALL_POS_Y, TILE_SIZE / 2}, // position
		Vec3{TILE_SIZE, WALL_HEIGHT_Y, WALL_WIDTH}, // size
		rl.DARKGRAY,
	)

	// back wall
	level.walls[level.wall_count] = create_wall(
		&level,
		Vec3{0, WALL_POS_Y, -(TILE_SIZE / 2)}, // position
		Vec3{TILE_SIZE, WALL_HEIGHT_Y, WALL_WIDTH}, // size
		rl.DARKGRAY,
	)

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
