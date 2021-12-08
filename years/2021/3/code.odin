package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:mem"
import "core:path"
import "shared:file"
import "core:math"


main_ :: proc() {
    input := string(#load("input.txt"))
    defer delete(input)

    rows := strings.split(input, "\n")
    defer delete(rows)

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
