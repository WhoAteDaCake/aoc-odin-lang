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

Action :: struct {
	command: string,
    steps: int,
}

parse_action :: proc(row: string) -> Action {
    parts := strings.split(row, " ")

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


// task_2 :: proc(values: []int) {
//     window_size := 3
//     larger := 0
//     prev := math.sum(values[0:window_size])
//     for i := 1; i < len(values) && i + window_size <= len(values); i += 1 {
//         acc := math.sum(values[i:i + window_size])
//         if acc > prev {
//             larger += 1
//         }
//         prev = acc
//     }
//     fmt.println(larger)
// }


main :: proc() {
    input := string(#load("input.txt"))
    defer delete(input)

    rows := strings.split(input, "\n")
    defer delete(rows)

    task_1(rows)
    // task_2(values)
}