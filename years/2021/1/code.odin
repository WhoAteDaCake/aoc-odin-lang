package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:mem"
import "core:path"
import "shared:file"
import "core:math"

task_1 :: proc(values: []int) {
    prev := values[0]
    inc := 0
    for value in values[1:] {
        if value > prev {
            inc += 1
        }
        prev = value
    }
    fmt.println(inc)
}


task_2 :: proc(values: []int) {
    window_size := 3
    larger := 0
    prev := math.sum(values[0:window_size])
    for i := 1; i < len(values) && i + window_size <= len(values); i += 1 {
        acc := math.sum(values[i:i + window_size])
        if acc > prev {
            larger += 1
        }
        prev = acc
    }
    fmt.println(larger)
}


main :: proc() {
    input := string(#load("input.txt"))
    defer delete(input)

    rows := strings.split(input, "\n")
    defer delete(rows)

    values := make([]int, len(rows))
    defer delete(values)

    for row, idx in rows {
        num, _ := strconv.parse_int(row)
        values[idx] = num
    }

    task_1(values)
    task_2(values)
}