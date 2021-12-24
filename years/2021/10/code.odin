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
import "core:slice"

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

CLOSE_SCORE_MAP := map[byte]int{
    ')' = 1,
    ']' = 2,
    '}' = 3,
    '>' = 4,
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

complete_score :: proc(row: []byte, id: int, closer: byte, completion: ^[dynamic]byte) -> (LineState, int) {
    idx := id
    for idx <= len(row) - 1 {
        selected := row[idx]
        if selected == closer {
            return .Fine, idx
        } else if selected in OPEN_PAIRS {
            status, end_idx := complete_score(row, idx + 1, OPEN_PAIRS[selected], completion)
            if status != .Fine {
                if status == .Incomplete {
                    append(completion, closer)
                    return .Incomplete, end_idx
                }
                return status, end_idx
            }
            idx = end_idx + 1
        } else {
            return .Corrupted, idx
        }
    }
    append(completion, closer)
    return .Incomplete, idx
}

complete_row :: proc(bytes: []byte) -> int {
    collection := make([dynamic][dynamic]byte)
    defer {
        for col in collection do delete(col)   
        delete(collection)
    }
    for i := 0; i < len(bytes) - 1; i += 1 {
        completion := make([dynamic]byte)
        _, idx := complete_score(bytes, i + 1, OPEN_PAIRS[bytes[i]], &completion)
        i = idx
        append(&collection, completion)
    }
    score := 0
    for col in collection {
        for c in col {
            score *= 5
            score += CLOSE_SCORE_MAP[c]
        }
        // fmt.println(string(col[:]), score)
    }
    return score
}

main_ :: proc() {
    rows := strings.split(input, "\n")
    defer delete(rows)

    score_1 := 0
    score_2 := make([dynamic]int)
    defer delete(score_2)

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
                score_1 += SCORE_MAP[row[i]]
            } else {
                completion := make([dynamic]byte)
                defer delete(completion)
                append(&score_2, complete_row(bytes))
            }
            break
        }
    }
    slice.sort(score_2[:])
    score_2_idx := len(score_2) / 2

    fmt.println(score_1)
    fmt.println(score_2[score_2_idx])
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
