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

suroundings :: proc(grid: [][]int, r_idx: int, c_idx: int, default: int) -> [4]int {
    row := grid[r_idx]
    col := row[c_idx]
    values := [4]int{default,default,default,default}
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
    return values
}

check_near :: proc(grid: ^[][]int, y: int, x: int, color: int) {
    if grid[y][x] != 0 {
        return
    }
    grid[y][x] = color
    // Top
    if y != 0 {
        check_near(grid, y - 1, x, color)
    }
    // Left
    if x != 0 {
        check_near(grid, y, x - 1, color)
    } 
    // Right
    if x != len(grid[y]) - 1 {
        check_near(grid, y, x + 1, color)
    }
    // Bottom
    if y != len(grid) - 1 {
        check_near(grid, y + 1, x, color)
    }
}


// TODO: use a recursive solution instead with a spread color.
task_2 ::proc(grid: [][]int) {
    marked := make([][]int, len(grid))
    defer {
        for row in marked do delete(row)
        delete(marked)
    }
    row_len := len(grid[0])
    for row, idx in grid {
        marked[idx] = make([]int, row_len)
        for col, cidx in row {
            marked[idx][cidx] = (0 if col != 9 else -1)
        }
    }
    last_color := 1
    for row, r_idx in marked {
        for col, c_idx in row {
            if col != 0 {
                continue
            }
            check_near(&marked, r_idx, c_idx, last_color)
            last_color += 1
        }
    }
    sizes := make([]int, last_color - 1)
    defer delete(sizes)

    for row, r_idx in marked {
        for col, c_idx in row {
            if col != -1 {
                sizes[col - 1] += 1
            }
        }
    }
    //
    slice.sort(sizes)
    largest := sizes[len(sizes) - 3:]
    combined := slice.reduce(largest, 1, proc(a: int, b: int) -> int do return a * b)
    fmt.println(combined)
    // for row, r_idx in marked {
    //     fmt.println(row)
    // }
}

task_1 :: proc(grid: [][]int) {
    risk := 0
    for row, r_idx in grid {
        for col, c_idx in row {
            values := suroundings(grid, r_idx, c_idx, 10)
            if all_higher(col, values[:]) {
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
    // task_1(grid)
    task_2(grid)
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
