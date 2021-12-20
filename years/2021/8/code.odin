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

input :: string(#load("input_small.txt"))

Row :: struct {
    inputs: []string,
    outputs: []string,
}
INDICE_LEN :: 7
UNIQUE_LEN_LOOKUP := map[int]int{
    2 = 1,
    4 = 4,
    3 = 7,
    7 = 9,
}
// Which slots need to be filled for a number
INDICES := [][dynamic]int {
    {0, 1, 2, 4, 5, 6}, //0
    {2, 5},//1
    {0, 2, 3, 4, 6},//2
    {0, 2, 3, 5, 6},//3
    {1, 2, 3, 5},//4
    {0, 1, 3, 5, 6},//5
    {0, 1, 3, 4, 5, 6},//6
    {0, 2, 5},//7
    {0, 1, 2, 3, 4, 5, 6},//8
    {0, 1, 2, 3, 5, 6},//9
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
            if len(entry) in UNIQUE_LEN_LOOKUP {
                acc += 1 
            }
        }
    }
    return acc
}

string_to_bytes :: proc(a: string) -> []byte {
    acc := make([]u8, len(a))
    for _, idx in a {
        acc[idx] = a[idx]
    }
    return acc
}


reduce_choices :: proc(lookup: [][]byte, checked: []bool) -> (int, int) {
    for choices, idx in lookup {
        if checked[idx] {
            continue
        }
        for s_choices, s_idx in lookup {
            if checked[idx] {
                continue
            }

            if idx != s_idx && len(choices) == 2 && slice.equal(choices, s_choices) {
                return idx, s_idx
            }
        }
    }
    return -1, -1
}

decode :: proc(row: Row) -> int {
    lookup := make([][]u8, INDICE_LEN)
    allowed := transmute ([]u8)strings.clone("acedgfb")
    for _, idx in lookup {
        lookup[idx] = make([]u8, len(allowed))
        for c, aix in allowed {
            lookup[idx][aix] = c
        }
    }

    // Find the unique layouts first 
    for entry in row.inputs {
        bytes := string_to_bytes(entry)
        if !(len(entry) in UNIQUE_LEN_LOOKUP) {
            continue 
        }
        // Now we know the layout of the number
        num := UNIQUE_LEN_LOOKUP[len(entry)]
        for indice in INDICES[num] {
            // fmt.println(indice, string(lookup[indice]))
            // Value not set, all values can be here
            if len(lookup[indice]) == 0 {
                lookup[indice] = bytes
                continue
            }
            if len(lookup[indice]) == 1 {
                continue
            }
            lookup[indice] = sslice.overlap(bytes, lookup[indice])
        }
    }

    for row, idx in lookup {
        fmt.println(idx, string(row))
    }
    fmt.println("----------")

    checked := make([]bool, len(lookup))
    for { 
        idx1, idx2 := reduce_choices(lookup, checked)
        if idx1 == -1 {
            break
        }
        checked[idx1] = true
        checked[idx2] = true
        for entry, idx in lookup {
            if idx == idx1 || idx == idx2 {
                continue
            }
            lookup[idx] = sslice.without(lookup[idx1], entry)
            delete(entry)
        }
    }

    slice.fill(checked, false)

    // Check if any are of len 1
    for {
        selected := -1
        for entries, idx in lookup {
            if len(entries) == 1 && !checked[idx] {
                selected = idx
                break
            }
        }
        if selected == -1 {
            break
        }
        checked[selected] = true
        for entry, idx in lookup {
            if idx == selected {
                continue
            }
            lookup[idx] = sslice.without(lookup[selected], entry)
            delete(entry)
        }
    }

    for row, idx in lookup {
        fmt.println(idx, string(row))
    }
    fmt.println("----------")

    // for row, idx in lookup {
    //     fmt.println(idx, string(row))
    // }
    // fmt.println("----------")

    return 0
} 

task_2 :: proc(rows: []Row) -> int {
    for row in rows {
        decode(row)
        break
    }
    return 0
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
    result_2 := task_2(parsed)
    // fmt.println(result_1)
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
            // printf("%v Leaked %v bytes\n", v.location, v.size)
        }
    }
}
