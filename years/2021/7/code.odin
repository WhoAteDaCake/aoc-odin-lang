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

task_1 :: proc(grouped: map[int]int) -> int {
    lowest := -1 
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
    return lowest
}

task_2 :: proc(grouped: map[int]int, end: int) -> int {
    lowest := -1
    for slot in 0..end {
        distance := 0
        for o_slot, value in grouped {
            calculated := 0
            for n in 1..(abs(o_slot - slot)) {
                calculated += n
            }
            distance += calculated * value
        }
        if lowest == -1 {
            lowest = distance
        }
        lowest = min(lowest, distance)
    } 
    return lowest
}

main_ :: proc() {
    nums := utils.numbers(input)
    defer delete(nums)

    grouped := make(map[int]int)
    defer delete(grouped)

    end := nums[0]
    for num in nums {
        end = max(end, num)
        grouped[num] += 1
    }

    // result_1 := task_1(grouped)
    result_2 := task_2(grouped, end)
    fmt.println(result_2)
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
