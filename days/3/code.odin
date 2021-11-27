package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:mem"
import "shared:file"   
// is_valid_v1 :: proc(row: Row) -> bool {
//     valid := 0
//     for char in row.password {
//         if char == row.letter {
//             valid += 1
//         }
//     }
//     return valid >= row.min && valid <= row.max 
// }

// is_valid_v2 :: proc(row: Row) -> bool {
//     l1 := rune(row.password[row.min - 1])
//     l2 := rune(row.password[row.max - 1])
//     return (l1 == row.letter && l2 != row.letter) || (l1 != row.letter && l2 == row.letter)
// }

task_1:: proc(lines: []string) -> int {
    width := len(lines[0])
    height := len(lines)
    x := 0
    y := 0
    step_x := 3
    step_y := 1
    tree_n := 0

    for y < height - 1 {
        y += step_y
        x += step_x
        if x >= width {
            x -= width
        }
        if lines[y][x] == '#' {
            tree_n += 1
        }
    }
    return tree_n
}

main :: proc() {
    raw, lines, err := file.lines("./days/3/input.txt")
    if err != nil {
        fmt.println("Failed")
        return
    }
    defer delete(lines)
    defer delete(raw)

    result_1 := task_1(lines)

    fmt.println(result_1)
}