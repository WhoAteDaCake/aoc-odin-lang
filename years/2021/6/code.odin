package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:mem"
import "core:path"
import "core:math"

input :: string(#load("input.txt"))

numbers :: proc(row: string) -> [dynamic]int {
    nums_raw := strings.split(row, ",")
    nums := make([dynamic]int, len(nums_raw))
    defer delete(nums_raw)
    for num, idx in nums_raw {
        dec,  _  := strconv.parse_int(num, 10)
        nums[idx] = dec
    }
    return nums
}

main_ :: proc() {
    nums := numbers(input)
    defer delete(nums)

    current := make(map[int]int)
    defer delete(current)
    next := make(map[int]int)
    defer delete(next)
    

    for num in nums {
        current[num] += 1
    }

    for idx in 0..(256 - 1) {
        for key, value in current {
            if key == 0 {
                next[8] += value
                next[6] += value
            } else if key != - 1 {
                next[key - 1] += value
            }
        }
        clear(&current)
        for key, value in next {
            current[key] = value   
        }
        clear(&next)
    }
    sum := 0
    for key, value in current {
        sum += value
        fmt.printf("%d:%d ", key, value)
    }
    fmt.printf("\n%d\n", sum)
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
