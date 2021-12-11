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

join_marks :: proc(m1: Mark, m2: Mark) -> Mark {
  return Mark{
    min(m1.x1, m2.x1),
    max(m1.x2, m2.x2),
    min(m1.y1, m2.y1),
    max(m1.y2, m2.y2),
  }
}

read_mark :: proc(row: string) -> Mark {
    mark: Mark
    libc.sscanf(strings.unsafe_string_to_cstring(row),"%d,%d -> %d, %d", &mark.x1, &mark.y1, &mark.x2, &mark.y2)

    if mark.x1 > mark.x2 {
        tmp := mark.x1
        mark.x1 = mark.x2
        mark.x2 = tmp
    }

    if mark.y1 > mark.y2 {
        tmp := mark.y1
        mark.y1 = mark.y2
        mark.y2 = tmp
    }
    return mark
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

    grid := make([][]int, area.y2 + 1)
    defer delete(grid)

    for y2 in 0..area.y2 {
      grid[y2] = make([]int, area.x2 + 1)
    }
    // Cleanup
    defer {
      for y2 in 0..area.y2 {
        delete(grid[y2])
      }
    }  

    for mark in marks {
        if !(mark.x1 == mark.x2 || mark.y1 == mark.y2) {
            continue
        }
        for y in (mark.y1)..(mark.y2) {
            for x in (mark.x1)..(mark.x2) {
                grid[y][x] += 1
            }
        }
    }

    large := 0
    for row in grid {
        // fmt.println(row)
        for cell in row {
            if cell >= 2 do large += 1
        }
    }
    fmt.println(large)
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