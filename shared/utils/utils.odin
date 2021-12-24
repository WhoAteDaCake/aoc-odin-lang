package utils

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:slice"
import "core:mem"

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

number_grid :: proc(input: string) -> [][]int {
    rows := strings.split(input, "\n")
    defer delete(rows)

    grid := make([][]int, len(rows))

    row_len := len(rows[0])
    for _, idx in rows {
        grid[idx] = make([]int, row_len)
    }

    for row, ridx in rows {
        bytes := string_to_bytes(row)
        defer delete(bytes)
        for b, idx in bytes do grid[ridx][idx] = (cast(int)b) - 48
    }
    return grid
}

allocate_grid :: proc(rows:int, cols: int, default: $T) -> [][]T {
    grid := make([][]T, rows)
    for _, idx in grid {
        grid[idx] = make([]T, rows)
        slice.fill(grid[idx], default)
    }
    return grid
}

delete_grid :: proc(grid: $T/[][]$E) {
    for row in grid do delete(row)
    delete(grid)
}

reset_grid :: proc(grid: $T/[][]$E) {
    for row in grid do mem.zero_slice(row)
}

print_number_grid :: proc(grid: $T/[][]$E) {
    for row in grid {
        for num in row {
            fmt.printf("%d", num)
        }
        fmt.print("\n")
    }
}