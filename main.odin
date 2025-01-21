package shaderbox

import    "core:fmt"
import    "core:math"
import rl "vendor:raylib"

// Constants
WINDOW_WIDTH  :: 640 * 2
WINDOW_HEIGHT :: 480 * 2

// Type and  defintions
Vector2i :: [2]int

Particle :: struct {
    id: u8,
    life_time: f32,
    position: Vector2i,
    velocity: rl.Vector2,
    color: rl.Color,
    did_update: bool,
}

grid: [WINDOW_WIDTH][WINDOW_HEIGHT]u8

main :: proc() {
    rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Shaderbox - Particle Playground")
    rl.SetTargetFPS(60)
    defer rl.CloseWindow()
    defer free_all(context.temp_allocator)

    for !rl.WindowShouldClose() {
	// Input
	if rl.IsMouseButtonPressed(.LEFT) {
	    // Add particle baesd on selection type
	    mouse_pos := rl.GetMousePosition()
	    add_particle(mouse_pos)
	}	

	// Update
	for x in 0..<WINDOW_WIDTH {
	    for y in 0..<WINDOW_HEIGHT {
	
	    }
	} 
	// Render
	rl.BeginDrawing()
	defer rl.EndDrawing()

	rl.ClearBackground(rl.GRAY)

    }

}

update_sand :: proc() {
    
}

update_water :: proc() {

}

add_particle :: proc(pos: rl.Vector2) {

}

draw_particle :: proc() {

}
