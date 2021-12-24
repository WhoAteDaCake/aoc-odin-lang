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

// input :: string(#load("input.txt"))
input :: string(#load("input_small.txt"))

main_ :: proc() {
    rows := strings.split(input, "\n")
    defer delete(rows)

    graph := make(map[string][dynamic]string)
    defer {
        for key, value in graph do delete(graph[key])
        delete(graph)
    }

    for row in rows {
        parts := strings.split(row, "-")
        defer delete(parts)
        parent := parts[0]
        child := parts[1]
        if !(parent in graph) {
            graph[parent] = make([dynamic]string)
        }
        append(&(graph[parent]), child)
    }
    fmt.println(graph)
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
