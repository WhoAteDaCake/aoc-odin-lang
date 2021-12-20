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

all_higher :: proc(number: int, numbers: []int) -> bool {
    for num in numbers {
        if num <= number {
            return false
        }
    }
    return true
}

task_1 :: proc(grid: [][]int) {
    risk := 0
    for row, r_idx in grid {
        for col, c_idx in row {
            values := [4]int{10, 10, 10, 10}
            // Top
            if r_idx != 0 {
                values[0] = grid[r_idx - 1][c_idx]
            }
            // Left
            if c_idx != 0 {
                values[1] = grid[r_idx][c_idx - 1]
            }
            // Right
            if c_idx != len(row) - 1 {
                values[2] = grid[r_idx][c_idx + 1]
            }
            // Bottom
            if r_idx != len(grid) -1 {
                values[3] = grid[r_idx + 1][c_idx]
            }
            if all_higher(col, values[:]) {
                fmt.println(col, values[:])
                risk += col + 1
            }
        } 
    }
    fmt.println(risk)
}

main_ :: proc() {
    rows := strings.split(input, "\n")
    defer delete(rows)

    grid := make([][]int, len(rows))
    defer {
        for row in grid do delete(row)
        delete(grid)
    }

    row_len := len(rows[0])
    for _, idx in rows {
        grid[idx] = make([]int, row_len)
    }

    for row, ridx in rows {
        bytes := utils.string_to_bytes(row)
        defer delete(bytes)
        for b, idx in bytes do grid[ridx][idx] = (cast(int)b) - 48
    }
    task_1(grid)
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
