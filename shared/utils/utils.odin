package utils

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"

numbers :: proc(row: string) -> []int {
    nums_raw := strings.split(row, ",")
    nums := make([]int, len(nums_raw))
    defer delete(nums_raw)
    for num, idx in nums_raw {
        dec,  _  := strconv.parse_int(num, 10)
        nums[idx] = dec
    }
    return nums
}

string_to_bytes :: proc(a: string) -> []byte {
    acc := make([]u8, len(a))
    for _, idx in a {
        acc[idx] = a[idx]
    }
    return acc
}