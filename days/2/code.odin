package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:mem"
import "shared:file"   

Row :: struct {
    min: int,
    max: int,
    letter: rune,
    password: string,
}

parse :: proc(row: string) -> Row {
    // Line is in a format of: [min-max char: password]
    col_idx := strings.index_any(row, ":")
    sep_idx := strings.index_any(row, "-")

    password := row[col_idx + 2 : len(row)]
    letter := rune(row[col_idx - 1])
    min, _ := strconv.parse_int(row[0:sep_idx]);
    max, _ := strconv.parse_int(row[sep_idx + 1: col_idx - 2]);

    return Row{min,max,letter,password}
}

is_valid :: proc(row: Row) -> bool {
    valid := 0
    for char in row.password {
        if char == row.letter {
            valid += 1
        }
    }
    return valid >= row.min && valid <= row.max 
}

main :: proc() {
    raw, lines, err := file.lines("./days/2/input.txt")
    if err != nil {
        fmt.println("Failed")
        return
    }
    defer delete(lines)
    defer delete(raw)
    
    count := 0
    for line, idx in lines {
        row := parse(line)
        valid := is_valid(row)
        if valid {
            count += 1
        }
    }
    fmt.println(count)
}



// main :: proc() {
//     using fmt

//     track: mem.Tracking_Allocator
//     mem.tracking_allocator_init(&track, context.allocator)
//     context.allocator = mem.tracking_allocator(&track)

//     main_()

//     if len(track.allocation_map) > 0 {
//         println()
//         for _, v in track.allocation_map {
//             printf("%v Leaked %v bytes\n", v.location, v.size)
//         }
//     }
// }
