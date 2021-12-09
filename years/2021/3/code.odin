package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:mem"
import "core:path"
import "shared:file"
import "core:math"

task_1::proc(rows: []string) {
    gama := make([]u8, len(rows[0]))
    defer delete(gama)
    epsilon := make([]u8, len(rows[0]))
    defer delete(epsilon)

    collection := make([]u8, len(rows))
    defer delete(collection)

    for x := 0; x < len(rows[0]); x += 1 {
        for y := 0; y < len(rows); y += 1 {
            collection[y] = rows[y][x]
        }
        ones := 0
        zeros := 0
        for char in collection {
            if char == '0' {
                zeros += 1
            } else {
                ones += 1
            }
        }
        if ones > zeros {
            gama[x] = '1'
            epsilon[x] = '0'
        } else {
            gama[x] = '0'
            epsilon[x] = '1'
        }
    }
    gama_n,  _  := strconv.parse_int(string(gama), 2);
    ep_n, _  := strconv.parse_int(string(epsilon), 2);
    fmt.println(gama_n * ep_n)
}

oxygen :: proc(one_count: int, zero_count: int) -> u8 {
    if zero_count > one_count {
        return '0'
    }
    return '1'
}

scrubber :: proc(one_count: int, zero_count: int) -> u8 {
    if one_count < zero_count {
        return '1'
    }
    return '0'
}

select_number :: proc(rows: [dynamic]string, idx: int, selector: proc(int, int) -> u8) -> int {
    zero_count := 0
    one_count := 0

    for row in rows {
        if row[idx] == '0' {
            zero_count += 1
        } else {
            one_count += 1
        }
    }
    selected: [dynamic]string
    defer delete(selected)
    symbol := selector(one_count, zero_count)

    for row in rows {
        if row[idx] == symbol {
            append(&selected, row)
        }
    }

    if len(selected) == 1 {
        dec,  _  := strconv.parse_int(selected[0], 2);
        return dec
    } else if len(selected) == 0 {
        fmt.println("No rows selected")
        os.exit(1)
    }
    return select_number(selected, idx + 1, selector)
}

task_2 :: proc(rows: []string) {
    dyn_rows := make([dynamic]string, len(rows))
    defer delete(dyn_rows)

    for row, idx in rows {
        dyn_rows[idx] = row
    }

    oxy := select_number(dyn_rows, 0, oxygen)
    scrub := select_number(dyn_rows, 0, scrubber)
    fmt.println(oxy * scrub)
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
