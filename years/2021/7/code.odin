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


main_ :: proc() {
    nums := utils.numbers(input)
    defer delete(nums)

    grouped := make(map[int]int)
    defer delete(grouped)

    for num in nums {
        grouped[num] += 1
    }

    lowest := -1
    // selected := 
    for slot, _ in grouped {
        distance := 0
        for o_slot, value in grouped {
            distance += abs(o_slot - slot) * value
        }
        if lowest == -1 {
            lowest = distance
        }
        lowest = min(lowest, distance)
    } 

    fmt.println(lowest)
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
