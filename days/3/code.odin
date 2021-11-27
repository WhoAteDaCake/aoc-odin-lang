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

task:: proc(lines: []string, step_x: int, step_y: int) -> int {
    width := len(lines[0])
    height := len(lines)
    x := 0
    y := 0
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

    r1 := task(lines, 1, 1)
    r2 := task(lines, 3, 1)
    r3 := task(lines, 5, 1)
    r4 := task(lines, 7, 1)
    r5 := task(lines, 1, 2)
    fmt.println(r2, r1 * r2 * r3 * r4 * r5)
}