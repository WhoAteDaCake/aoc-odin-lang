package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "shared:file"   

main :: proc() {
    raw, err := file.lines("./days/2/input.txt")
    if err != nil {
        fmt.println("Failed")
        return
    }
    defer delete(lines)
    defer delete(raw)
}