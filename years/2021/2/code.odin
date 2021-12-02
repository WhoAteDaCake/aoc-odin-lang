package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:mem"
import "core:path"
import "shared:file"
import "core:math"

Vector2 :: struct {
	x: int,
	y: int,
}

PositionWithAim :: struct {
	x: int,
	y: int,
    aim: int,
}

Action :: struct {
	command: string,
    steps: int,
 }

parse_action :: proc(row: string) -> Action {
    parts := strings.split(row, " ")
    defer delete(parts)

    num, _ := strconv.parse_int(parts[1])    
    return Action{parts[0], num}
}

task_1 :: proc(rows: []string) {
    pos := Vector2{0, 0}
    for row in rows {
        action := parse_action(row)
        switch action.command {
        case "forward":
            pos.x += action.steps
        case "down":
            pos.y += action.steps
        case "up":
            pos.y -= action.steps    
        }
    }
    fmt.println(pos.x * pos.y)
}

task_2 :: proc(rows: []string) {
    pos := PositionWithAim{0, 0, 0}
    for row in rows {
        action := parse_action(row)
        steps := action.steps
        switch action.command {
        case "forward":
            pos.x += steps
            pos.y += pos.aim * steps
        case "down":
            // pos.y += steps
            pos.aim += steps
        case "up":
            // pos.y -= steps
            pos.aim -= steps    
        }
        // fmt.println(pos)
    }
    fmt.println(pos.x * pos.y)
}

main_ :: proc() {
    input := string(#load("input.txt"))
    defer delete(input)

    rows := strings.split(input, "\n")
    defer delete(rows)

    task_1(rows)
    task_2(rows)
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
