package shaderbox

import    "core:fmt"
import    "core:math"
import    "core:math/rand"
import rl "vendor:raylib"

// Constants
WINDOW_WIDTH  :: 360 * 3
WINDOW_HEIGHT :: 240 * 3
CELL_SIZE     :: 4
GRID_SIZE_X   :: WINDOW_WIDTH / CELL_SIZE
GRID_SIZE_Y   :: WINDOW_HEIGHT / CELL_SIZE
GRAVITY       :: -9.8
ADD_RADIUS    :: 5
MIN_PARTICLES :: 5
MAX_PARTICLES :: 20

// Type and  defintions
Vector2i :: [2]int

Particle :: struct {
    id: ParticleType,
    life_time: f32,
    position: Vector2i,
    velocity: rl.Vector2,
    color: rl.Color,
    did_update: bool,
}

ParticleType :: enum(u8) {
    Empty = 0,
    Sand = 1,
    Water = 2,
    Stone = 3,
}

grid := [GRID_SIZE_X][GRID_SIZE_Y]Particle{}
selected_type := ParticleType.Empty
is_radius := false

main :: proc() {
    rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Shaderbox - Particle Playground")
    rl.SetTargetFPS(60)
    defer rl.CloseWindow()
    defer free_all(context.temp_allocator)

    for !rl.WindowShouldClose() {
	// Input
	if rl.IsMouseButtonDown(.LEFT) {
	    // TODO: Add particle baesd on selection type
	    mouse_pos := rl.GetMousePosition()
	    grid_x := int(mouse_pos.x) / CELL_SIZE
	    grid_y := int(mouse_pos.y) / CELL_SIZE

	    if in_bounds(grid_x, grid_y) {
		add_particle({grid_x, grid_y}, selected_type)  
	    }
	}

	if rl.IsMouseButtonPressed(.RIGHT) {
	    is_radius = !is_radius
	}

	// Update
	for y := GRID_SIZE_Y - 1; y >= 0; y -= 1 {
	    for x in 0..<GRID_SIZE_X {
		p_id := grid[x][y].id

		#partial switch p_id {
		case .Sand:
		    update_sand({x,y})
		    break;
		case .Water:
		    update_water({x,y})
		}
	    }
	} 

	// Render
	rl.BeginDrawing()
	defer rl.EndDrawing()

	rl.ClearBackground(rl.BLACK)
	draw_particles()
	draw_selector()

    }

}

in_bounds :: proc(x, y: int) -> bool {
    return x >= 0 && x < GRID_SIZE_X && y >= 0 && y < GRID_SIZE_Y
}

is_empty :: proc(x, y: int) -> bool {
    return in_bounds(x, y) && grid[x][y].id == .Empty
}

can_move_down :: proc(pos: Vector2i) -> bool {
    x, y := pos.x, pos.y
    return in_bounds(x, y + 1) && is_empty(x, y + 1)
}

can_move_diagonally :: proc(pos: Vector2i) -> bool {
    x, y := pos.x, pos.y
    return (in_bounds(x - 1, y + 1) && is_empty(x - 1, y + 1)) ||
           (in_bounds(x + 1, y + 1) && is_empty(x + 1, y + 1))
}

update_sand :: proc(pos: Vector2i) {
    x, y := pos.x, pos.y

    if in_bounds(x, y + 1) && is_empty(x, y + 1){
        // Move sand down
        grid[x][y + 1] = grid[x][y]
	grid[x][y].id = .Empty
	return
    } else if in_bounds(x - 1, y + 1) && is_empty(x - 1, y + 1) {
        // Move sand down-left
        grid[x - 1][y + 1] = grid[x][y]
        grid[x][y].id = .Empty
	return
    } else if in_bounds(x + 1, y + 1) && is_empty(x + 1, y + 1) {
        // Move sand down-right
        grid[x + 1][y + 1] = grid[x][y]
        grid[x][y].id = .Empty
	return
    }
 
}

update_water :: proc(pos: Vector2i) {
    x, y := pos.x, pos.y

    // Check downwards first
    if in_bounds(x, y + 1) && is_empty(x, y + 1) {
        // Move water down
        grid[x][y + 1] = grid[x][y]
        grid[x][y].id = .Empty
        return
    }

    // Randomly decide whether to check left or right first
    if rand.int_max(100) % 2 == 0 { 
        // Check left first
        if in_bounds(x - 1, y) && is_empty(x - 1, y) {
            grid[x - 1][y] = grid[x][y]
            grid[x][y].id = .Empty
            return
        }
        // Then right
        if in_bounds(x + 1, y) && is_empty(x + 1, y) {
            grid[x + 1][y] = grid[x][y]
            grid[x][y].id = .Empty
            return
        }
    } else {
        // Check right first
        if in_bounds(x + 1, y) && is_empty(x + 1, y) {
            grid[x + 1][y] = grid[x][y]
            grid[x][y].id = .Empty
            return
        }
        // Then left
        if in_bounds(x - 1, y) && is_empty(x - 1, y) {
            grid[x - 1][y] = grid[x][y]
            grid[x][y].id = .Empty
            return
        }
    }

    // Check diagonal movements only if we can't go straight down or horizontally
    if in_bounds(x - 1, y + 1) && is_empty(x - 1, y + 1) {
        grid[x - 1][y + 1] = grid[x][y]
        grid[x][y].id = .Empty
        return
    }
    if in_bounds(x + 1, y + 1) && is_empty(x + 1, y + 1) {
        grid[x + 1][y + 1] = grid[x][y]
        grid[x][y].id = .Empty
        return
    }
}



update_stone :: proc(pos: Vector2i) {
    x, y := pos.x, pos.y

    // Stone stays in place
    if in_bounds(x, y) && is_empty(x, y){
        grid[x][y] = grid[x][y]
	return
    }
}

add_particle :: proc(pos: Vector2i, type: ParticleType) {

    // Single Particle at a time
    if !is_radius {
	if grid[pos.x][pos.y].id == .Empty {
	    #partial switch type {
	    case .Sand:
		grid[pos.x][pos.y].id = .Sand
		grid[pos.x][pos.y].color = rl.YELLOW
	    case .Water:
		grid[pos.x][pos.y].id = .Water
		grid[pos.x][pos.y].color = rl.BLUE
	    case .Stone:
		grid[pos.x][pos.y].id = .Stone
		grid[pos.x][pos.y].color = rl.GRAY
	    }
	}
    }
    else {
	// Circle radius of paticles
	num_particles := rand.int_max(MAX_PARTICLES)

	for _ in 0..<num_particles {
	    // Generate random angle and distance within the circle
	    angle := f32(rand.float64_range(0, 2*math.PI))
	    distance := f32(rand.float64_range(0, ADD_RADIUS))

	    // Convert polar coordinates to grid coordinates
	    dx := int(math.round(math.cos(angle) * distance))
	    dy := int(math.round(math.sin(angle) * distance))
	    
	    x,y := pos.x, pos.y 
	    particle_pos := Vector2i{x + dx, y + dy}
	    
	    if in_bounds(particle_pos.x, particle_pos.y) && grid[particle_pos.x][particle_pos.y].id == .Empty {
		grid[particle_pos.x][particle_pos.y].id = type
		#partial switch type {
		case .Sand:
		    grid[particle_pos.x][particle_pos.y].color = rl.YELLOW
		case .Water:
		    grid[particle_pos.x][particle_pos.y].color = rl.BLUE
		case .Stone:
		    grid[particle_pos.x][particle_pos.y].color = rl.GRAY
		}
	    }
	}
    }
}

// TODO: Turn this into more of a toggle switch? Make sure when clicking them no new particles are created until after. Also show selection
draw_selector :: proc() {
    if rl.GuiButton(rl.Rectangle{10, 10, 60, 30}, "Sand") {
	selected_type = .Sand
    }

    if rl.GuiButton(rl.Rectangle{80, 10, 60, 30}, "Water") {
	selected_type = .Water
    }
    
    if rl.GuiButton(rl.Rectangle{150, 10, 60, 30}, "Stone") {
	selected_type = .Stone
    }

}

draw_particles :: proc() {
    for y in 0..<GRID_SIZE_Y {
        for x in 0..<GRID_SIZE_X {
            particle := &grid[x][y]

	    #partial switch particle.id {
	    case .Sand:
		rl.DrawRectangle(i32(x * CELL_SIZE), i32(y * CELL_SIZE), CELL_SIZE, CELL_SIZE, particle.color)
	    case .Water:
		rl.DrawRectangle(i32(x * CELL_SIZE), i32(y * CELL_SIZE), CELL_SIZE, CELL_SIZE, particle.color)
	    case .Stone:
		rl.DrawRectangle(i32(x * CELL_SIZE), i32(y * CELL_SIZE), CELL_SIZE, CELL_SIZE, particle.color)
	    } 
        }
    }
}
