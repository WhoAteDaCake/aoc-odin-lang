package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:mem"
import "core:path"
import "core:math"
import "shared:utils"

input :: string(#load("input.txt"))

Row :: struct {
    inputs: []string,
    outputs: []string,
}

parse_row :: proc(row: string) -> Row {
    entries := strings.split(row, " ")
    defer delete(entries)

    signals := make([]string, 10)

    for idx in 0..9 {
        signals[idx] = entries[idx]
    }

    output := make([]string, 4)
    for idx in 0..3 {
        output[idx] = entries[idx + 11]
    }

    return Row{signals, output}
}

task_1 :: proc(rows: []Row) -> int {
    acc := 0
    for row in rows {
        for entry in row.outputs {
            size := len(entry)
            if size == 2 || size == 4 || size == 3 || size == 7 {
                acc += 1
            }
        }
    }
    return acc
}

main_ :: proc() {
    rows := strings.split(input, "\n")
    defer delete(rows)
    parsed := make([]Row, len(rows))
    defer {
        for row in parsed {
            delete(row.inputs)
            delete(row.outputs)
        }
        delete(parsed)
    }

    for row, idx in rows {
        parsed[idx] = parse_row(row)
    }
    result_1 := task_1(parsed)
    fmt.println(result_1)
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
