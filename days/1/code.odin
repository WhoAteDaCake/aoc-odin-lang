package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "shared:file"   

main :: proc() {
    raw, err := file.read_file("./days/1/input.txt")
    if err != nil {
        fmt.println("Failed")
    }
    defer delete(raw)
    text := string(raw)
    defer delete(text)
    lines := strings.split(text, "\n")
    defer delete(lines)

    numbers := make([]u64, len(lines))
    defer delete(numbers)

    for line, idx in lines {
        n, ok := strconv.parse_u64_of_base(line, 10);
        numbers[idx] = n 
    }
    loop: for num_1 in numbers {
        for num_2 in numbers {
            if num_1 + num_2 == 2020 {
                fmt.println(num_1 * num_2)
                break loop
            }
        }
    }

    loop_3: for num_1 in numbers {
        for num_2 in numbers {
            for num_3 in numbers {
                if num_1 + num_2 + num_3 == 2020 {
                    fmt.println(num_1 * num_2 * num_3)
                    break loop_3
                }
            }
        }
    }
}