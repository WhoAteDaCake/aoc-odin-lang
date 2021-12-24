package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:mem"
import "core:path"
import "core:math"
import "shared:utils"
import "core:time"

LineState :: enum {
	Fine,
    Corrupted,
    Incomplete,
};

// input :: string(#load("input_small.txt"))
input :: string(#load("input.txt"))

SCORE_MAP := map[byte]int{
    ')' = 3,
    ']' = 57,
    '}' = 1197,
    '>' = 25137,
}

OPEN_PAIRS := map[byte]byte{
    '(' = ')',
    '[' = ']',
    '{' = '}',
    '<' = '>',
}

CLOSERS := map[byte]bool{
    ')' = true,
    ']' = true,
    '}' = true,
    '>' = true,
}

check_symbol :: proc(row: []byte, id: int, closer: byte, nested: int) -> (LineState, int) {
    idx := id
    for idx < len(row) - 1 {
        selected := row[idx]
        if selected == closer {
            return .Fine, idx
        } else if selected in OPEN_PAIRS {
            status, end_idx := check_symbol(row, idx + 1, OPEN_PAIRS[selected], nested + 1)
            if status != .Fine {
                return status, end_idx
            }
            idx = end_idx + 1
        } else {
            return .Corrupted, idx
        }
    }
    return .Incomplete, idx
}

main_ :: proc() {
    rows := strings.split(input, "\n")
    defer delete(rows)

    score := 0
    for row in rows {
        bytes := utils.string_to_bytes(row)
        defer delete(bytes)
        for i := 0; i < len(bytes) - 1; i += 1 {
            status, idx := check_symbol(bytes, i + 1, OPEN_PAIRS[bytes[i]], 0)
            i = idx
            if status == .Fine {
                continue 
            }
            if status == .Corrupted {
                // fmt.printf("%s, %s ", status, row)
                score += SCORE_MAP[row[i]]
                // fmt.println(rune(row[i]))
            }
            break
        }
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
