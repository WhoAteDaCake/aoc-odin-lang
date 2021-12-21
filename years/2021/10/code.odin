package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:mem"
import "core:path"
import "core:math"
import "shared:utils"

input :: string(#load("input_small.txt"))
// input :: string(#load("input.txt"))

SCORE_MAP := map[byte]int{
    ')' = 3,
    ']' = 57,
    '}' = 1197,
    '>' = 25137,
}

CLOSERS := map[byte]byte{
    '(' = ')',
    '[' = ']',
    '{' = '}',
    '<' = '>',
}

check_symbol :: proc(row: []byte, idx: int, closer: byte) -> (bool, int) {
    id := idx
    for {
        selected := row[id]
        fmt.println(idx, rune(selected), rune(closer), string(row[id:]))
        if selected == closer {
            return false, id
        } else if selected in CLOSERS {
            failed, id := check_symbol(row, id + 1, CLOSERS[selected])
            if failed {
                return failed, id
            }
            fmt.println("Found", idx, id)
        } else {
            return true, id
        }     
    }
}

main_ :: proc() {
    rows := strings.split(input, "\n")
    defer delete(rows)

    score := 0
    for row in rows {
        bytes := utils.string_to_bytes(row)
        defer delete(bytes)

        for i := 0; i < len(bytes); i += 1 {
            failed, idx := check_symbol(bytes, i + 1, CLOSERS[bytes[i]])
            i := idx
            if failed {
                score += SCORE_MAP[row[i]]
                fmt.println(rune(row[i]))
                break
            }
        }
        break
    }
    fmt.println(score)
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
