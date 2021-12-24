package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:mem"
import "core:path"
import "core:math"
import "core:slice"

import "shared:utils"
import "shared:sslice"

input :: string(#load("input.txt"))
// input :: string(#load("input_small.txt"))

Point :: struct {
    y: int,
    x: int,
}

suroundings :: proc(grid: [][]int, y: int, x: int) -> []Point {
    row := grid[y]
    col := row[x]
    values := make([dynamic]Point)

    for y_n := max(y - 1, 0); y_n <= y + 1 && y_n < len(grid); y_n += 1 {
        for x_n := max(x - 1, 0); x_n <= x + 1 && x_n < len(row); x_n += 1 {
            if y_n == y && x_n == x {
                continue 
            }
            append(&values, Point{y_n, x_n})
        }
    }
    return values[:]
}

perform_step :: proc(grid: ^[][]int, y: int, x: int, marked: ^[][]bool) {
    if marked[y][x] {
        return
    }

    cell := grid[y][x]
    cell += 1
    if cell > 9 && !marked[y][x] {
        cell = 0
    }
    if cell > 9 {
        cell = 9
    }
    grid[y][x] = cell
    if cell == 0 {
        marked[y][x] = true
        points := suroundings(grid^, y, x)
        defer delete(points)
        for p in points {
            perform_step(grid, p.y, p.x, marked)
        }
    }
}

task_1 :: proc(grid: ^[][]int) {
    marked := utils.allocate_grid(len(grid), len(grid[0]), false)
    defer utils.delete_grid(marked)

    flashes := 0
    for step in 1..100 {
        fmt.println(step)
        for row, y in grid {
            for _, x in row {
                perform_step(grid, y, x, &marked)
            }
        }
        for row in marked {
            for val in row {
                flashes += cast(int)val
            }
            // flashes += math.sum(transmute ([]int)row)
        }
        utils.print_number_grid(grid^)
        utils.reset_grid(marked)
    } 
    fmt.println(flashes)
}


task_2 :: proc(grid: ^[][]int) {
    marked := utils.allocate_grid(len(grid), len(grid[0]), false)
    defer utils.delete_grid(marked)

    step := 1
    for {
        fmt.println(step)
        for row, y in grid {
            for _, x in row {
                perform_step(grid, y, x, &marked)
            }
        }
        check := true
        for row in marked {
            for val in row {
                check = check && val
            }
        }

        utils.print_number_grid(grid^)
        utils.reset_grid(marked)
        if check {
            break
        }
        step += 1
    } 
    fmt.println(step)
}


main_ :: proc() {
    grid := utils.number_grid(input)
    defer utils.delete_grid(grid)
    // task_1(&grid)
    task_2(&grid)
}

main :: proc() {
    using fmt

    track: mem.Tracking_Allocator
    mem.tracking_allocator_init(&track, context.allocator)
    context.allocator = mem.tracking_allocator(&track)

    main_()

    if len(track.allocation_map) > 0 {
        println()
        for _, v in track.allocation_map {
            printf("%v Leaked %v bytes\n", v.location, v.size)
        }
    }
}
