package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:mem"
import "core:path"
import "core:math"

import libc "core:c/libc"

Mark :: struct {
  x1: int,
  x2: int,
  y1: int,
  y2: int,
}

Step :: struct {
    y: int,
    x: int,
}

join_marks :: proc(m1: Mark, m2: Mark) -> Mark {
  return Mark{
    min(m1.x1, m1.x2, m2.x1, m2.x2),
    max(m1.x1, m1.x2, m2.x1, m2.x2),
    min(m1.y1, m1.y2, m2.y1, m2.y2),
    max(m1.y1, m1.y2, m2.y1, m2.y2),
  }
}

sorted :: proc(v1: int, v2: int) -> (int, int) {
    if v1 > v2 {
        return v2, v1
    }
    return v1, v2
}

mark_steps :: proc(m: Mark, line_only: bool) -> [dynamic]Step {
    steps := make([dynamic]Step)
    using m
    // Not diagonal
    if x1 == x2 || y1 == y2 {
        y_min, y_max := sorted(y1, y2)
        x_min, x_max := sorted(x1, x2)
        for y in y_min..y_max {
            for x in x_min..x_max {
                append(&steps, Step{y, x})
            }
        }
    } else if !line_only {

    }
    // Diagonal
    return steps
}

read_mark :: proc(row: string) -> Mark {
    mark: Mark
    libc.sscanf(strings.unsafe_string_to_cstring(row),"%d,%d -> %d, %d", &mark.x1, &mark.y1, &mark.x2, &mark.y2)
    return mark
}

task :: proc(grid: ^[][]int, marks: []Mark, lines_only: bool) -> int {
    fmt.println(marks)
    for mark in marks {
        steps := mark_steps(mark, lines_only)
        defer delete(steps)
        for step in steps {
            grid[step.y][step.x] += 1
        }
    }

    large := 0
    for row in grid {
        for cell in row {
            if cell >= 2 do large += 1
            if cell == 0 {
                fmt.print(".")
            } else {
                fmt.print(cell)
            }
        }
        fmt.print("\n")
    }
    return large
} 


main_ :: proc() {
    input := string(#load("input.txt"))
    defer delete(input)

    rows := strings.split(input, "\n")
    defer delete(rows)

    marks := make([]Mark, len(rows))
    defer delete(marks)

    for row, idx in rows {
      marks[idx] = read_mark(row)
    }

    area := marks[0]
    for mark in marks[1:] { 
      area = join_marks(area, mark)
    }

    _, y_max := sorted(area.y1, area.y2)
    grid := make([][]int, y_max + 1)
    defer delete(grid)

    _, x_max := sorted(area.x1, area.x2)
    for y2 in 0..area.y2 {
      grid[y2] = make([]int, x_max + 1)
    }
    // Cleanup
    defer {
      for y2 in 0..area.y2 {
        delete(grid[y2])
      }
    }  

    result := task(&grid, marks, true)
    // result := task(&grid, marks, false)
    fmt.println(result)
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