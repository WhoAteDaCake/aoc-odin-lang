package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"

Error :: enum {
    None,
    Open,
    File_Size,
    Read,
}

read_file :: proc(file: string) -> ([]u8, Error) {
    f, err_no := os.open(file)
    if err_no != 0 {
        return nil, .Open
    }
    defer os.close(f)
    //
    size: i64
    size, err_no = os.file_size(f)
    if err_no != 0 {
        return nil, .File_Size
    }
    // EOF
    size += 1

    data := make([]u8, size)
    // defer delete(data)

    bytes_read: int
    bytes_read, err_no = os.read(f, data)
    if err_no != 0 {
        return nil, .Read
    }
    // text := string(data)
    return data, .None
}   

main :: proc() {
    raw, err := read_file("./input.txt")
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